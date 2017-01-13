package pt.ua.ieeta.rpacs;

import com.avaje.ebean.Ebean;
import com.avaje.ebean.Transaction;
import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.URI;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.function.Consumer;
import org.dcm4che2.data.DicomObject;
import org.dcm4che2.data.Tag;
import org.dcm4che2.io.DicomInputStream;
import org.dcm4che2.io.StopTagInputHandler;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import pt.ua.dicoogle.sdk.IndexerInterface;
import pt.ua.dicoogle.sdk.StorageInputStream;
import pt.ua.dicoogle.sdk.datastructs.IndexReport2;
import pt.ua.dicoogle.sdk.datastructs.Report;
import pt.ua.dicoogle.sdk.task.Task;
import pt.ua.ieeta.rpacs.model.Image;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.model.Serie;
import pt.ua.ieeta.rpacs.model.Study;
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase;

@SuppressWarnings("all")
public class RPacsIndexer extends RPacsPluginBase implements IndexerInterface {
  private final static Logger logger = LoggerFactory.getLogger(RPacsIndexer.class);
  
  @Accessors
  private final String name = "r-pacs-indexer";
  
  @Override
  public boolean handles(final URI uri) {
    return true;
  }
  
  @Override
  public boolean unindex(final URI uri) {
    return false;
  }
  
  @Override
  public Task<Report> index(final StorageInputStream file, final Object... parameters) {
    return this.index(Collections.<StorageInputStream>unmodifiableList(CollectionLiterals.<StorageInputStream>newArrayList(file)), parameters);
  }
  
  @Override
  public Task<Report> index(final Iterable<StorageInputStream> streams, final Object... objects) {
    Task _xblockexpression = null;
    {
      int _size = IterableExtensions.size(streams);
      String _plus = ("Start Index-List: " + Integer.valueOf(_size));
      RPacsIndexer.logger.info(_plus);
      final Callable<IndexReport2> _function = () -> {
        final IndexReport2 report = new IndexReport2();
        final Consumer<StorageInputStream> _function_1 = (StorageInputStream it) -> {
          boolean _indexStream = this.indexStream(it);
          if (_indexStream) {
            report.addIndexFile();
          } else {
            report.addError();
          }
        };
        streams.forEach(_function_1);
        return report;
      };
      _xblockexpression = new Task(_function);
    }
    return _xblockexpression;
  }
  
  public boolean indexStream(final StorageInputStream storage) {
    try {
      URI _uRI = storage.getURI();
      RPacsIndexer.logger.info("INDEXING - {}", _uRI);
      InputStream _inputStream = storage.getInputStream();
      BufferedInputStream _bufferedInputStream = new BufferedInputStream(_inputStream);
      final DicomInputStream dicomStream = new DicomInputStream(_bufferedInputStream);
      try {
        StopTagInputHandler _stopTagInputHandler = new StopTagInputHandler(Tag.PixelData);
        dicomStream.setHandler(_stopTagInputHandler);
        final DicomObject dim = dicomStream.readDicomObject();
        final String patientID = dim.getString(Tag.PatientID);
        final String studyUID = dim.getString(Tag.StudyInstanceUID);
        final String serieUID = dim.getString(Tag.SeriesInstanceUID);
        final String imageUID = dim.getString(Tag.SOPInstanceUID);
        final Transaction tx = Ebean.beginTransaction();
        Image _elvis = null;
        Image _findByUID = Image.findByUID(imageUID);
        if (_findByUID != null) {
          _elvis = _findByUID;
        } else {
          Image _image = new Image();
          _elvis = _image;
        }
        final Procedure1<Image> _function = (Image it) -> {
          it.setUid(imageUID);
          int _int = dim.getInt(Tag.InstanceNumber);
          it.setNumber(Integer.valueOf(_int));
          String _string = dim.getString(Tag.PhotometricInterpretation);
          it.setPhotometric(_string);
          int _int_1 = dim.getInt(Tag.Columns);
          it.setColumns(Integer.valueOf(_int_1));
          int _int_2 = dim.getInt(Tag.Rows);
          it.setRows(Integer.valueOf(_int_2));
        };
        final Image eImage = ObjectExtensions.<Image>operator_doubleArrow(_elvis, _function);
        Long _id = eImage.getId();
        boolean _tripleNotEquals = (_id != null);
        if (_tripleNotEquals) {
          tx.rollback();
          RPacsIndexer.logger.info("ALREADY-INDEXED - ({}, {}, {}, {})", patientID, studyUID, serieUID, imageUID);
          return true;
        }
        Serie _elvis_1 = null;
        Serie _findByUID_1 = Serie.findByUID(serieUID);
        if (_findByUID_1 != null) {
          _elvis_1 = _findByUID_1;
        } else {
          Serie _serie = new Serie();
          _elvis_1 = _serie;
        }
        final Procedure1<Serie> _function_1 = (Serie it) -> {
          it.setUid(serieUID);
          int _int = dim.getInt(Tag.SeriesNumber);
          it.setNumber(Integer.valueOf(_int));
          String _elvis_2 = null;
          String _string = dim.getString(Tag.SeriesDescription);
          if (_string != null) {
            _elvis_2 = _string;
          } else {
            _elvis_2 = "";
          }
          it.setDescription(_elvis_2);
          String _string_1 = dim.getString(Tag.SeriesDate);
          final LocalDate date = LocalDate.parse(_string_1, DateTimeFormatter.BASIC_ISO_DATE);
          String _elvis_3 = null;
          String _string_2 = dim.getString(Tag.SeriesTime);
          if (_string_2 != null) {
            _elvis_3 = _string_2;
          } else {
            _elvis_3 = "000000";
          }
          DateTimeFormatter _ofPattern = DateTimeFormatter.ofPattern("HHmmss[.SSS]");
          final LocalTime time = LocalTime.parse(_elvis_3, _ofPattern);
          LocalDateTime _of = LocalDateTime.of(date, time);
          it.setDatetime(_of);
          String _string_3 = dim.getString(Tag.Modality);
          it.setModality(_string_3);
          String _string_4 = dim.getString(Tag.Laterality);
          it.setLaterality(_string_4);
        };
        final Serie eSerie = ObjectExtensions.<Serie>operator_doubleArrow(_elvis_1, _function_1);
        List<Image> _images = eSerie.getImages();
        _images.add(eImage);
        Long _id_1 = eSerie.getId();
        boolean _tripleNotEquals_1 = (_id_1 != null);
        if (_tripleNotEquals_1) {
          eSerie.save();
          tx.commit();
          RPacsIndexer.logger.info("INDEXED - ({}, {}, {}, {})", patientID, studyUID, serieUID, imageUID);
          return true;
        }
        Study _elvis_2 = null;
        Study _findByUID_2 = Study.findByUID(studyUID);
        if (_findByUID_2 != null) {
          _elvis_2 = _findByUID_2;
        } else {
          Study _study = new Study();
          _elvis_2 = _study;
        }
        final Procedure1<Study> _function_2 = (Study it) -> {
          it.setUid(studyUID);
          String _string = dim.getString(Tag.StudyID);
          it.setSid(_string);
          String _string_1 = dim.getString(Tag.AccessionNumber);
          it.setAccessionNumber(_string_1);
          String _elvis_3 = null;
          String _string_2 = dim.getString(Tag.StudyDescription);
          if (_string_2 != null) {
            _elvis_3 = _string_2;
          } else {
            _elvis_3 = "";
          }
          it.setDescription(_elvis_3);
          String _string_3 = dim.getString(Tag.StudyDate);
          final LocalDate date = LocalDate.parse(_string_3, DateTimeFormatter.BASIC_ISO_DATE);
          String _elvis_4 = null;
          String _string_4 = dim.getString(Tag.StudyTime);
          if (_string_4 != null) {
            _elvis_4 = _string_4;
          } else {
            _elvis_4 = "000000";
          }
          DateTimeFormatter _ofPattern = DateTimeFormatter.ofPattern("HHmmss[.SSS]");
          final LocalTime time = LocalTime.parse(_elvis_4, _ofPattern);
          LocalDateTime _of = LocalDateTime.of(date, time);
          it.setDatetime(_of);
          String _elvis_5 = null;
          String _string_5 = dim.getString(Tag.InstitutionName);
          if (_string_5 != null) {
            _elvis_5 = _string_5;
          } else {
            _elvis_5 = "";
          }
          it.setInstitutionName(_elvis_5);
          String _elvis_6 = null;
          String _string_6 = dim.getString(Tag.InstitutionAddress);
          if (_string_6 != null) {
            _elvis_6 = _string_6;
          } else {
            _elvis_6 = "";
          }
          it.setInstitutionAddress(_elvis_6);
        };
        final Study eStudy = ObjectExtensions.<Study>operator_doubleArrow(_elvis_2, _function_2);
        List<Serie> _series = eStudy.getSeries();
        _series.add(eSerie);
        Long _id_2 = eStudy.getId();
        boolean _tripleNotEquals_2 = (_id_2 != null);
        if (_tripleNotEquals_2) {
          eStudy.save();
          tx.commit();
          RPacsIndexer.logger.info("INDEXED - ({}, {}, {}, {})", patientID, studyUID, serieUID, imageUID);
          return true;
        }
        Patient _elvis_3 = null;
        Patient _findByPID = Patient.findByPID(patientID);
        if (_findByPID != null) {
          _elvis_3 = _findByPID;
        } else {
          Patient _patient = new Patient();
          _elvis_3 = _patient;
        }
        final Procedure1<Patient> _function_3 = (Patient it) -> {
          it.setPid(patientID);
          String _string = dim.getString(Tag.PatientName);
          it.setName(_string);
          String _string_1 = dim.getString(Tag.PatientSex);
          it.setSex(_string_1);
          String _string_2 = dim.getString(Tag.PatientBirthDate);
          LocalDate _parse = LocalDate.parse(_string_2, DateTimeFormatter.BASIC_ISO_DATE);
          it.setBirthdate(_parse);
        };
        final Patient ePatient = ObjectExtensions.<Patient>operator_doubleArrow(_elvis_3, _function_3);
        List<Study> _studies = ePatient.getStudies();
        _studies.add(eStudy);
        ePatient.save();
        tx.commit();
        RPacsIndexer.logger.info("INDEXED - ({}, {}, {}, {})", patientID, studyUID, serieUID, imageUID);
        return true;
      } catch (final Throwable _t) {
        if (_t instanceof Exception) {
          final Exception e = (Exception)_t;
          Ebean.rollbackTransaction();
          URI _uRI_1 = storage.getURI();
          RPacsIndexer.logger.error("INDEX-FAILED - {}", _uRI_1);
          return false;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      } finally {
        dicomStream.close();
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Pure
  public String getName() {
    return this.name;
  }
}
