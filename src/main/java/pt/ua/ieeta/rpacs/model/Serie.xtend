package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.annotation.Index
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.HashMap
import java.util.List
import java.util.Map
import javax.persistence.Column
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

@XEntity
class Serie {
	
	@ManyToOne
	@NotNull Study study
	
	@Index
	@Column(unique=true)
	@NotNull String uid
	
	@NotNull Integer number
	
	@NotNull String description
	@NotNull LocalDateTime datetime
	
	@NotNull String modality
	
	//Equipment
	String stationName
	String manufacturer
	String manufacturerModelName
	
	@OneToMany(mappedBy = "serie", cascade = ALL)
	List<Image> images
	
	def Map<String, Object> toFlatDicom() {
		new HashMap<String, Object> => [
			put(Tag.SeriesInstanceUID.tagName, uid)
			put(Tag.SeriesNumber.tagName, number)
			put(Tag.SeriesDescription.tagName, description)
			put(Tag.SeriesDate.tagName, datetime.format(DateTimeFormatter.BASIC_ISO_DATE))
			put(Tag.SeriesTime.tagName, datetime.format(DateTimeFormatter.ofPattern('HHmmss[.SSS]')))
			put(Tag.Modality.tagName, modality)
			
			putAll(study.toFlatDicom)
		]
	}
	
	def static findByUID(String uid) {
		Serie.find.query.where.eq('uid', uid).findUnique
	}
}