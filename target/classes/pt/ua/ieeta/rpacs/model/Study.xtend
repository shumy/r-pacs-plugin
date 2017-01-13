package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.annotation.Index
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.HashMap
import java.util.List
import javax.persistence.Column
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*
import java.util.ArrayList

@XEntity
class Study {
	
	@ManyToOne
	@JoinColumn(name="ref_patient")
	@NotNull Patient patient
	
	@Index
	@Column(unique=true)
	@NotNull String uid
	@NotNull String sid
	@NotNull String accessionNumber
	
	@NotNull String description
	@NotNull LocalDateTime datetime
	
	@NotNull String institutionName
	@NotNull String institutionAddress
	
	//@Field Integer NumberOfStudyRelatedSeries
	
	@OneToMany(mappedBy = "study", cascade = ALL)
	List<Serie> series
	
	def toFlatDicom() {
		val List<HashMap<String, Object>> flatResult = new ArrayList<HashMap<String, Object>>
		
		series.forEach[ serie |
			serie.toFlatDicom.forEach[
				put(Tag.StudyInstanceUID.tagName, uid)
				put(Tag.StudyID.tagName, sid)
				put(Tag.AccessionNumber.tagName, accessionNumber)
				put(Tag.StudyDescription.tagName, description)
				put(Tag.StudyDate.tagName, datetime.format(DateTimeFormatter.BASIC_ISO_DATE))
				put(Tag.StudyTime.tagName, datetime.format(DateTimeFormatter.ofPattern('HHmmss[.SSS]')))
				put(Tag.InstitutionName.tagName, institutionName)
				put(Tag.InstitutionAddress.tagName, institutionAddress)
				flatResult.add(it)
			]
		]
		
		return flatResult
	}
	
	def static findByUID(String uid) {
		Study.find.query.where.eq('uid', uid).findUnique
	}
}