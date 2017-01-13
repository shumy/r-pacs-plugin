package pt.ua.ieeta.rpacs.model;

import com.avaje.ebean.ExpressionList;
import com.avaje.ebean.Finder;
import com.avaje.ebean.Query;
import com.avaje.ebean.annotation.Index;
import com.fasterxml.jackson.annotation.JsonGetter;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.OneToMany;
import javax.validation.constraints.NotNull;
import org.dcm4che2.data.Tag;
import org.eclipse.xtext.xbase.lib.Pure;
import pt.ua.ieeta.rpacs.model.DicomTags;
import pt.ua.ieeta.rpacs.model.Study;
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
import shy.xhelper.ebean.json.gen.GenJson;

@XEntity
@Entity
@GenAccessors
@GenJson
@SuppressWarnings("all")
public class Patient extends BaseModel implements IEntity, IJson {
  @Index
  @Column(unique = true)
  @NotNull
  private String pid;
  
  @NotNull
  private String name;
  
  @NotNull
  private String sex;
  
  @NotNull
  @JsonSerialize(using = LocalDateTimeSerializer.class)
  @JsonDeserialize(using = LocalDateTimeDeserializer.class)
  private LocalDate birthdate;
  
  @JsonGetter
  public long getAge() {
    LocalDate _now = LocalDate.now();
    return ChronoUnit.YEARS.between(this.birthdate, _now);
  }
  
  @OneToMany(mappedBy = "patient", cascade = CascadeType.ALL)
  @JsonSerialize(using = CollectionSerializer.class)
  @JsonDeserialize(using = CollectionDeserializer.class)
  private List<Study> studies;
  
  public List<HashMap<String, Object>> toFlatDicom() {
    final List<HashMap<String, Object>> flatResult = new ArrayList<HashMap<String, Object>>();
    final Consumer<Study> _function = (Study study) -> {
      List<HashMap<String, Object>> _flatDicom = study.toFlatDicom();
      final Consumer<HashMap<String, Object>> _function_1 = (HashMap<String, Object> it) -> {
        String _tagName = DicomTags.tagName(Tag.PatientID);
        it.put(_tagName, this.pid);
        String _tagName_1 = DicomTags.tagName(Tag.PatientName);
        it.put(_tagName_1, this.name);
        String _tagName_2 = DicomTags.tagName(Tag.PatientSex);
        it.put(_tagName_2, this.sex);
        String _tagName_3 = DicomTags.tagName(Tag.PatientBirthDate);
        String _format = this.birthdate.format(DateTimeFormatter.BASIC_ISO_DATE);
        it.put(_tagName_3, _format);
        String _tagName_4 = DicomTags.tagName(Tag.PatientAge);
        long _age = this.getAge();
        it.put(_tagName_4, Long.valueOf(_age));
        flatResult.add(it);
      };
      _flatDicom.forEach(_function_1);
    };
    this.studies.forEach(_function);
    return flatResult;
  }
  
  public static Patient findByPID(final String pid) {
    Query<Patient> _query = Patient.find.query();
    ExpressionList<Patient> _where = _query.where();
    ExpressionList<Patient> _eq = _where.eq("pid", pid);
    return _eq.findUnique();
  }
  
  @Pure
  public String getPid() {
    return this.pid;
  }
  
  @Pure
  public String getName() {
    return this.name;
  }
  
  @Pure
  public String getSex() {
    return this.sex;
  }
  
  @Pure
  public LocalDate getBirthdate() {
    return this.birthdate;
  }
  
  @Pure
  public List<Study> getStudies() {
    return this.studies;
  }
  
  public Patient setPid(final String pid) {
    this.pid = pid;
    return this;
  }
  
  public Patient setName(final String name) {
    this.name = name;
    return this;
  }
  
  public Patient setSex(final String sex) {
    this.sex = sex;
    return this;
  }
  
  public Patient setBirthdate(final LocalDate birthdate) {
    this.birthdate = birthdate;
    return this;
  }
  
  public Patient setStudies(final List<Study> studies) {
    this.studies = studies;
    return this;
  }
  
  public static Patient fromJson(final String jsonString) {
    try {
    	return JsonDynamicProfile.deserialize(Patient.class, jsonString);
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
  
  public final static Finder<Long, Patient> find = new Finder<>(Patient.class);
}
