package pt.ua.ieeta.rpacs.model;

import com.avaje.ebean.ExpressionList;
import com.avaje.ebean.Finder;
import com.avaje.ebean.Query;
import com.avaje.ebean.annotation.Index;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.validation.constraints.NotNull;
import org.dcm4che2.data.Tag;
import org.eclipse.xtext.xbase.lib.Pure;
import pt.ua.ieeta.rpacs.model.DicomTags;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.model.Serie;
import shy.xhelper.data.gen.GenAccessors;
import shy.xhelper.ebean.BaseModel;
import shy.xhelper.ebean.IEntity;
import shy.xhelper.ebean.XEntity;
import shy.xhelper.ebean.json.IJson;
import shy.xhelper.ebean.json.JsonDynamicProfile;
import shy.xhelper.ebean.json.converter.CollectionDeserializer;
import shy.xhelper.ebean.json.converter.CollectionSerializer;
import shy.xhelper.ebean.json.converter.LocalDateTimeDeserializer;
import shy.xhelper.ebean.json.converter.LocalDateTimeSerializer;
import shy.xhelper.ebean.json.converter.RefDeserializer;
import shy.xhelper.ebean.json.converter.RefSerializer;
import shy.xhelper.ebean.json.gen.GenJson;

@XEntity
@Entity
@GenAccessors
@GenJson
@SuppressWarnings("all")
public class Study extends BaseModel implements IEntity, IJson {
  @ManyToOne
  @JoinColumn(name = "ref_patient")
  @NotNull
  @JsonSerialize(using = RefSerializer.class)
  @JsonDeserialize(using = RefDeserializer.class)
  private Patient patient;
  
  @Index
  @Column(unique = true)
  @NotNull
  private String uid;
  
  @NotNull
  private String sid;
  
  @NotNull
  private String accessionNumber;
  
  @NotNull
  private String description;
  
  @NotNull
  @JsonSerialize(using = LocalDateTimeSerializer.class)
  @JsonDeserialize(using = LocalDateTimeDeserializer.class)
  private LocalDateTime datetime;
  
  @NotNull
  private String institutionName;
  
  @NotNull
  private String institutionAddress;
  
  @OneToMany(mappedBy = "study", cascade = CascadeType.ALL)
  @JsonSerialize(using = CollectionSerializer.class)
  @JsonDeserialize(using = CollectionDeserializer.class)
  private List<Serie> series;
  
  public List<HashMap<String, Object>> toFlatDicom() {
    final List<HashMap<String, Object>> flatResult = new ArrayList<HashMap<String, Object>>();
    final Consumer<Serie> _function = (Serie serie) -> {
      List<HashMap<String, Object>> _flatDicom = serie.toFlatDicom();
      final Consumer<HashMap<String, Object>> _function_1 = (HashMap<String, Object> it) -> {
        String _tagName = DicomTags.tagName(Tag.StudyInstanceUID);
        it.put(_tagName, this.uid);
        String _tagName_1 = DicomTags.tagName(Tag.StudyID);
        it.put(_tagName_1, this.sid);
        String _tagName_2 = DicomTags.tagName(Tag.AccessionNumber);
        it.put(_tagName_2, this.accessionNumber);
        String _tagName_3 = DicomTags.tagName(Tag.StudyDescription);
        it.put(_tagName_3, this.description);
        String _tagName_4 = DicomTags.tagName(Tag.StudyDate);
        String _format = this.datetime.format(DateTimeFormatter.BASIC_ISO_DATE);
        it.put(_tagName_4, _format);
        String _tagName_5 = DicomTags.tagName(Tag.StudyTime);
        DateTimeFormatter _ofPattern = DateTimeFormatter.ofPattern("HHmmss[.SSS]");
        String _format_1 = this.datetime.format(_ofPattern);
        it.put(_tagName_5, _format_1);
        String _tagName_6 = DicomTags.tagName(Tag.InstitutionName);
        it.put(_tagName_6, this.institutionName);
        String _tagName_7 = DicomTags.tagName(Tag.InstitutionAddress);
        it.put(_tagName_7, this.institutionAddress);
        flatResult.add(it);
      };
      _flatDicom.forEach(_function_1);
    };
    this.series.forEach(_function);
    return flatResult;
  }
  
  public static Study findByUID(final String uid) {
    Query<Study> _query = Study.find.query();
    ExpressionList<Study> _where = _query.where();
    ExpressionList<Study> _eq = _where.eq("uid", uid);
    return _eq.findUnique();
  }
  
  @Pure
  public Patient getPatient() {
    return this.patient;
  }
  
  @Pure
  public String getUid() {
    return this.uid;
  }
  
  @Pure
  public String getSid() {
    return this.sid;
  }
  
  @Pure
  public String getAccessionNumber() {
    return this.accessionNumber;
  }
  
  @Pure
  public String getDescription() {
    return this.description;
  }
  
  @Pure
  public LocalDateTime getDatetime() {
    return this.datetime;
  }
  
  @Pure
  public String getInstitutionName() {
    return this.institutionName;
  }
  
  @Pure
  public String getInstitutionAddress() {
    return this.institutionAddress;
  }
  
  @Pure
  public List<Serie> getSeries() {
    return this.series;
  }
  
  public Study setPatient(final Patient patient) {
    this.patient = patient;
    return this;
  }
  
  public Study setUid(final String uid) {
    this.uid = uid;
    return this;
  }
  
  public Study setSid(final String sid) {
    this.sid = sid;
    return this;
  }
  
  public Study setAccessionNumber(final String accessionNumber) {
    this.accessionNumber = accessionNumber;
    return this;
  }
  
  public Study setDescription(final String description) {
    this.description = description;
    return this;
  }
  
  public Study setDatetime(final LocalDateTime datetime) {
    this.datetime = datetime;
    return this;
  }
  
  public Study setInstitutionName(final String institutionName) {
    this.institutionName = institutionName;
    return this;
  }
  
  public Study setInstitutionAddress(final String institutionAddress) {
    this.institutionAddress = institutionAddress;
    return this;
  }
  
  public Study setSeries(final List<Serie> series) {
    this.series = series;
    return this;
  }
  
  public static Study fromJson(final String jsonString) {
    try {
    	return JsonDynamicProfile.deserialize(Study.class, jsonString);
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
  
  public final static Finder<Long, Study> find = new Finder<>(Study.class);
}
