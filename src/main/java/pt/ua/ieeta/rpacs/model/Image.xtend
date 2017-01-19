package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.annotation.Index
import java.util.HashMap
import java.util.List
import javax.persistence.Column
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import pt.ua.ieeta.rpacs.model.ext.Annotation
import pt.ua.ieeta.rpacs.model.ext.Lesion
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

@XEntity
class Image {
	
	@ManyToOne
	@NotNull Serie serie
	
	@Index
	@Column(unique=true)
	@NotNull String uid
	
	@NotNull Integer number
	
	@NotNull String photometric
	@NotNull Integer columns
	@NotNull Integer rows
	
	@NotNull String laterality
	
	@OneToMany(mappedBy = "image", cascade = ALL)
	List<Annotation> annotations
	
	@OneToMany(mappedBy = "image", cascade = ALL)
	List<Lesion> lesions
	
	def HashMap<String, Object> toFlatDicom() {
		new HashMap<String, Object> => [
			put(Tag.SOPInstanceUID.tagName, uid)
			put(Tag.InstanceNumber.tagName, number)
			put(Tag.PhotometricInterpretation.tagName, photometric)
			put(Tag.Columns.tagName, columns)
			put(Tag.Rows.tagName, rows)
			put(Tag.Laterality.tagName, laterality)
			
			//NOTE: because of dicoogle bug, uri's must be just with one slash -> / 
			put('uri', '''file:/«serie.study.patient.pid»/«uid».dcm''')
		]
	}
	
	def static findByUID(String uid) {
		Image.find.query.where.eq('uid', uid).findUnique
	}
}