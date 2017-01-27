package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.annotation.Index
import com.fasterxml.jackson.annotation.JsonGetter
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import java.util.HashMap
import java.util.List
import java.util.Map
import javax.persistence.Column
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

// model from http://dicomiseasy.blogspot.pt/2011/12/chapter-4-dicom-objects-in-chapter-3.html
@XEntity
class Patient {
	
	@Index
	@Column(unique=true)
	@NotNull String pid
	
	@NotNull String name
	@NotNull String sex
	
	@NotNull LocalDate birthdate
	
	@OneToMany(mappedBy = "patient", cascade = ALL)
	List<Study> studies
	
	@JsonGetter
	def getAge() { ChronoUnit.YEARS.between(birthdate, LocalDate.now) }
	
	def Map<String, Object> toFlatDicom() {
		new HashMap<String, Object> => [
			put(Tag.PatientID.tagName, pid)
			put(Tag.PatientName.tagName, name)
			put(Tag.PatientSex.tagName, sex)
			put(Tag.PatientBirthDate.tagName, birthdate.format(DateTimeFormatter.BASIC_ISO_DATE))
			put(Tag.PatientAge.tagName, age)
		]
	}
	
	def static findByPID(String pid) {
		Patient.find.query.where.eq('pid', pid).findUnique
	}
}