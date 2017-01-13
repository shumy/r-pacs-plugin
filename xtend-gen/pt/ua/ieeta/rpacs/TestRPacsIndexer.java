package pt.ua.ieeta.rpacs;

import com.avaje.ebean.Ebean;
import com.avaje.ebean.EbeanServerFactory;
import com.avaje.ebean.cache.ServerCacheManager;
import com.avaje.ebean.config.ServerConfig;
import java.util.ArrayList;
import java.util.HashMap;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import pt.ua.dicoogle.sdk.datastructs.SearchResult;
import pt.ua.ieeta.rpacs.DicomInputStream;
import pt.ua.ieeta.rpacs.RPacsIndexer;
import pt.ua.ieeta.rpacs.RPacsQuery;
import pt.ua.ieeta.rpacs.model.Image;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.model.Serie;
import pt.ua.ieeta.rpacs.model.Study;

@SuppressWarnings("all")
public class TestRPacsIndexer {
  @BeforeClass
  public static void setup() {
    ServerConfig _serverConfig = new ServerConfig();
    final Procedure1<ServerConfig> _function = (ServerConfig it) -> {
      it.setName("db");
      it.setDefaultServer(true);
      it.loadTestProperties();
    };
    final ServerConfig config = ObjectExtensions.<ServerConfig>operator_doubleArrow(_serverConfig, _function);
    EbeanServerFactory.create(config);
  }
  
  @Test
  public void indexAndQueryDicomFile() {
    final RPacsIndexer indexer = new RPacsIndexer();
    final RPacsQuery query = new RPacsQuery("h2://mem:tests");
    DicomInputStream _dicomInputStream = new DicomInputStream("1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm");
    indexer.indexStream(_dicomInputStream);
    DicomInputStream _dicomInputStream_1 = new DicomInputStream("1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1.dcm");
    indexer.indexStream(_dicomInputStream_1);
    DicomInputStream _dicomInputStream_2 = new DicomInputStream("1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1.dcm");
    indexer.indexStream(_dicomInputStream_2);
    DicomInputStream _dicomInputStream_3 = new DicomInputStream("1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1.dcm");
    indexer.indexStream(_dicomInputStream_3);
    ServerCacheManager _serverCacheManager = Ebean.getServerCacheManager();
    _serverCacheManager.clearAll();
    Image _byId = Image.find.byId(Long.valueOf(1L));
    final Procedure1<Image> _function = (Image it) -> {
      String _json = it.toJson();
      Assert.assertEquals("{\"id\":1,\"version\":1,\"serie\":1,\"uid\":\"1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1\",\"number\":1,\"photometric\":\"RGB\",\"columns\":3456,\"rows\":2304}", _json);
    };
    ObjectExtensions.<Image>operator_doubleArrow(_byId, _function);
    Serie _byId_1 = Serie.find.byId(Long.valueOf(1L));
    final Procedure1<Serie> _function_1 = (Serie it) -> {
      String _json = it.toJson();
      Assert.assertEquals("{\"id\":1,\"version\":1,\"study\":1,\"uid\":\"1.2.392.200046.100.3.8.101983.6649.20160504112902.1\",\"number\":1,\"description\":\"Color/R\",\"datetime\":\"2016-05-04T11:29:01\",\"modality\":\"XC\",\"laterality\":\"R\"}", _json);
    };
    ObjectExtensions.<Serie>operator_doubleArrow(_byId_1, _function_1);
    Study _byId_2 = Study.find.byId(Long.valueOf(1L));
    final Procedure1<Study> _function_2 = (Study it) -> {
      String _json = it.toJson();
      Assert.assertEquals("{\"id\":1,\"version\":1,\"patient\":1,\"uid\":\"1.2.826.0.1.3680043.2.1174.4.1.5.1961172\",\"sid\":\"0000\",\"accessionNumber\":\"R051961172\",\"description\":\"Retinografia\",\"datetime\":\"2016-05-04T11:28:09\",\"institutionName\":\"Anonymized institution\"}", _json);
    };
    ObjectExtensions.<Study>operator_doubleArrow(_byId_2, _function_2);
    Patient _byId_3 = Patient.find.byId(Long.valueOf(1L));
    final Procedure1<Patient> _function_3 = (Patient it) -> {
      String _json = it.toJson();
      Assert.assertEquals("{\"id\":1,\"version\":1,\"pid\":\"250520161135441091\",\"name\":\"Anonymized patient\",\"sex\":\"M\",\"birthdate\":\"1941-10-18\",\"age\":75}", _json);
    };
    ObjectExtensions.<Patient>operator_doubleArrow(_byId_3, _function_3);
    final ArrayList<SearchResult> sResults = query.queryText("name:Anonymized and  sex:  M and   studies.accessionNumber: R051961172  ");
    int _size = sResults.size();
    Assert.assertEquals(4, _size);
    SearchResult _get = sResults.get(0);
    final HashMap<String, Object> result0 = _get.getExtraData();
    SearchResult _get_1 = sResults.get(1);
    final HashMap<String, Object> result1 = _get_1.getExtraData();
    SearchResult _get_2 = sResults.get(2);
    final HashMap<String, Object> result2 = _get_2.getExtraData();
    SearchResult _get_3 = sResults.get(3);
    final HashMap<String, Object> result3 = _get_3.getExtraData();
    String _string = result0.toString();
    Assert.assertEquals("{InstanceNumber=1, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1, SeriesDescription=Color/R, PhotometricInterpretation=RGB, SeriesNumber=1, Laterality=R, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1, SeriesTime=112901.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=file:/250520161135441091/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}", _string);
    String _string_1 = result1.toString();
    Assert.assertEquals("{InstanceNumber=2, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1, SeriesDescription=Color/R, PhotometricInterpretation=RGB, SeriesNumber=1, Laterality=R, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1, SeriesTime=112901.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=file:/250520161135441091/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}", _string_1);
    String _string_2 = result2.toString();
    Assert.assertEquals("{InstanceNumber=1, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2, SeriesDescription=Color/L, PhotometricInterpretation=RGB, SeriesNumber=2, Laterality=L, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1, SeriesTime=112927.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=file:/250520161135441091/1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}", _string_2);
    String _string_3 = result3.toString();
    Assert.assertEquals("{InstanceNumber=2, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2, SeriesDescription=Color/L, PhotometricInterpretation=RGB, SeriesNumber=2, Laterality=L, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1, SeriesTime=112927.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=file:/250520161135441091/1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}", _string_3);
  }
}
