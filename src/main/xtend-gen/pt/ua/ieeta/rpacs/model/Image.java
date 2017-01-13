package pt.ua.ieeta.rpacs.model;

import com.avaje.ebean.ExpressionList;
import com.avaje.ebean.Finder;
import com.avaje.ebean.Query;
import com.avaje.ebean.annotation.Index;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import java.util.HashMap;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.NotNull;
import org.dcm4che2.data.Tag;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import pt.ua.ieeta.rpacs.model.DicomTags;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.model.Serie;
import pt.ua.ieeta.rpacs.model.Study;
import shy.xhelper.data.gen.GenAccessors;
import shy.xhelper.ebean.BaseModel;
import shy.xhelper.ebean.IEntity;
import shy.xhelper.ebean.XEntity;
import shy.xhelper.ebean.json.IJson;
import shy.xhelper.ebean.json.JsonDynamicProfile;
import shy.xhelper.ebean.json.converter.RefDeserializer;
import shy.xhelper.ebean.json.converter.RefSerializer;
import shy.xhelper.ebean.json.gen.GenJson;

@XEntity
@Entity
@GenAccessors
@GenJson
@SuppressWarnings("all")
public class Image extends BaseModel implements IEntity, IJson {
  @ManyToOne
  @JoinColumn(name = "ref_serie")
  @NotNull
  @JsonSerialize(using = RefSerializer.class)
  @JsonDeserialize(using = RefDeserializer.class)
  private Serie serie;
  
  @Index
  @Column(unique = true)
  @NotNull
  private String uid;
  
  @NotNull
  private Integer number;
  
  @NotNull
  private String photometric;
  
  @NotNull
  private Integer columns;
  
  @NotNull
  private Integer rows;
  
  public HashMap<String, Object> toFlatDicom() {
    HashMap<String, Object> _hashMap = new HashMap<String, Object>();
    final Procedure1<HashMap<String, Object>> _function = (HashMap<String, Object> pMap) -> {
      String _tagName = DicomTags.tagName(Tag.SOPInstanceUID);
      pMap.put(_tagName, this.uid);
      String _tagName_1 = DicomTags.tagName(Tag.InstanceNumber);
      pMap.put(_tagName_1, this.number);
      String _tagName_2 = DicomTags.tagName(Tag.PhotometricInterpretation);
      pMap.put(_tagName_2, this.photometric);
      String _tagName_3 = DicomTags.tagName(Tag.Columns);
      pMap.put(_tagName_3, this.columns);
      String _tagName_4 = DicomTags.tagName(Tag.Rows);
      pMap.put(_tagName_4, this.rows);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("file:/");
      Study _study = this.serie.getStudy();
      Patient _patient = _study.getPatient();
      String _pid = _patient.getPid();
      _builder.append(_pid, "");
      _builder.append("/");
      _builder.append(this.uid, "");
      _builder.append(".dcm");
      pMap.put("uri", _builder);
    };
    return ObjectExtensions.<HashMap<String, Object>>operator_doubleArrow(_hashMap, _function);
  }
  
  public static Image findByUID(final String uid) {
    Query<Image> _query = Image.find.query();
    ExpressionList<Image> _where = _query.where();
    ExpressionList<Image> _eq = _where.eq("uid", uid);
    return _eq.findUnique();
  }
  
  @Pure
  public Serie getSerie() {
    return this.serie;
  }
  
  @Pure
  public String getUid() {
    return this.uid;
  }
  
  @Pure
  public Integer getNumber() {
    return this.number;
  }
  
  @Pure
  public String getPhotometric() {
    return this.photometric;
  }
  
  @Pure
  public Integer getColumns() {
    return this.columns;
  }
  
  @Pure
  public Integer getRows() {
    return this.rows;
  }
  
  public Image setSerie(final Serie serie) {
    this.serie = serie;
    return this;
  }
  
  public Image setUid(final String uid) {
    this.uid = uid;
    return this;
  }
  
  public Image setNumber(final Integer number) {
    this.number = number;
    return this;
  }
  
  public Image setPhotometric(final String photometric) {
    this.photometric = photometric;
    return this;
  }
  
  public Image setColumns(final Integer columns) {
    this.columns = columns;
    return this;
  }
  
  public Image setRows(final Integer rows) {
    this.rows = rows;
    return this;
  }
  
  public static Image fromJson(final String jsonString) {
    try {
    	return JsonDynamicProfile.deserialize(Image.class, jsonString);
    } catch(Throwable ex) {
    	throw new RuntimeException(ex);
    }
  }
  
  public String toJson() {
    try {
    	return JsonDynamicProfile.serialize(this);
    } catch(Throwable ex) {
    	throw new RuntimeException(ex);
    }
  }
  
  public final static Finder<Long, Image> find = new Finder<>(Image.class);
}
