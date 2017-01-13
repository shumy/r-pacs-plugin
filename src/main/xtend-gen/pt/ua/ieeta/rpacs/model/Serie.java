package pt.ua.ieeta.rpacs.model;

import com.avaje.ebean.ExpressionList;
import com.avaje.ebean.Finder;
import com.avaje.ebean.Query;
import com.avaje.ebean.annotation.Index;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.validation.constraints.NotNull;
import org.dcm4che2.data.Tag;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import pt.ua.ieeta.rpacs.model.DicomTags;
import pt.ua.ieeta.rpacs.model.Image;
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
import shy.xhelper.ebean.json.converter.RefDeserializer;
import shy.xhelper.ebean.json.converter.RefSerializer;
import shy.xhelper.ebean.json.gen.GenJson;

@XEntity
@Entity
@GenAccessors
@GenJson
@SuppressWarnings("all")
public class Serie extends BaseModel implements IEntity, IJson {
  @ManyToOne
  @JoinColumn(name = "ref_study")
  @NotNull
  @JsonSerialize(using = RefSerializer.class)
  @JsonDeserialize(using = RefDeserializer.class)
  private Study study;
  
  @Index
  @Column(unique = true)
  @NotNull
  private String uid;
  
  @NotNull
  private Integer number;
  
  @NotNull
  private String description;
  
  @NotNull
  @JsonSerialize(using = LocalDateTimeSerializer.class)
  @JsonDeserialize(using = LocalDateTimeDeserializer.class)
  private LocalDateTime datetime;
  
  @NotNull
  private String modality;
  
  @NotNull
  private String laterality;
  
  @OneToMany(mappedBy = "serie", cascade = CascadeType.ALL)
  @JsonSerialize(using = CollectionSerializer.class)
  @JsonDeserialize(using = CollectionDeserializer.class)
  private List<Image> images;
  
  public List<HashMap<String, Object>> toFlatDicom() {
    final Function1<Image, HashMap<String, Object>> _function = (Image image) -> {
      HashMap<String, Object> _flatDicom = image.toFlatDicom();
      final Procedure1<HashMap<String, Object>> _function_1 = (HashMap<String, Object> it) -> {
        String _tagName = DicomTags.tagName(Tag.SeriesInstanceUID);
        it.put(_tagName, this.uid);
        String _tagName_1 = DicomTags.tagName(Tag.SeriesNumber);
        it.put(_tagName_1, this.number);
        String _tagName_2 = DicomTags.tagName(Tag.SeriesDescription);
        it.put(_tagName_2, this.description);
        String _tagName_3 = DicomTags.tagName(Tag.SeriesDate);
        String _format = this.datetime.format(DateTimeFormatter.BASIC_ISO_DATE);
        it.put(_tagName_3, _format);
        String _tagName_4 = DicomTags.tagName(Tag.SeriesTime);
        DateTimeFormatter _ofPattern = DateTimeFormatter.ofPattern("HHmmss[.SSS]");
        String _format_1 = this.datetime.format(_ofPattern);
        it.put(_tagName_4, _format_1);
        String _tagName_5 = DicomTags.tagName(Tag.Modality);
        it.put(_tagName_5, this.modality);
        String _tagName_6 = DicomTags.tagName(Tag.Laterality);
        it.put(_tagName_6, this.laterality);
      };
      return ObjectExtensions.<HashMap<String, Object>>operator_doubleArrow(_flatDicom, _function_1);
    };
    final List<HashMap<String, Object>> flatResult = ListExtensions.<Image, HashMap<String, Object>>map(this.images, _function);
    return flatResult;
  }
  
  public static Serie findByUID(final String uid) {
    Query<Serie> _query = Serie.find.query();
    ExpressionList<Serie> _where = _query.where();
    ExpressionList<Serie> _eq = _where.eq("uid", uid);
    return _eq.findUnique();
  }
  
  @Pure
  public Study getStudy() {
    return this.study;
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
  public String getDescription() {
    return this.description;
  }
  
  @Pure
  public LocalDateTime getDatetime() {
    return this.datetime;
  }
  
  @Pure
  public String getModality() {
    return this.modality;
  }
  
  @Pure
  public String getLaterality() {
    return this.laterality;
  }
  
  @Pure
  public List<Image> getImages() {
    return this.images;
  }
  
  public Serie setStudy(final Study study) {
    this.study = study;
    return this;
  }
  
  public Serie setUid(final String uid) {
    this.uid = uid;
    return this;
  }
  
  public Serie setNumber(final Integer number) {
    this.number = number;
    return this;
  }
  
  public Serie setDescription(final String description) {
    this.description = description;
    return this;
  }
  
  public Serie setDatetime(final LocalDateTime datetime) {
    this.datetime = datetime;
    return this;
  }
  
  public Serie setModality(final String modality) {
    this.modality = modality;
    return this;
  }
  
  public Serie setLaterality(final String laterality) {
    this.laterality = laterality;
    return this;
  }
  
  public Serie setImages(final List<Image> images) {
    this.images = images;
    return this;
  }
  
  public static Serie fromJson(final String jsonString) {
    try {
    	return JsonDynamicProfile.deserialize(Serie.class, jsonString);
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
  
  public final static Finder<Long, Serie> find = new Finder<>(Serie.class);
}
