package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.annotation.Index
import java.util.HashMap
import javax.persistence.Column
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

@XEntity
class Image {
	
	@ManyToOne
	@JoinColumn(name="ref_serie")
	@NotNull Serie serie
	
	@Index
	@Column(unique=true)
	@NotNull String uid
	@NotNull Integer number
	
	@NotNull String photometric
	@NotNull Integer columns
	@NotNull Integer rows
	
	def HashMap<String, Object> toFlatDicom() {
		new HashMap<String, Object> => [ pMap |
			pMap.put(Tag.SOPInstanceUID.tagName, uid)
			pMap.put(Tag.InstanceNumber.tagName, number)
			pMap.put(Tag.PhotometricInterpretation.tagName, photometric)
			pMap.put(Tag.Columns.tagName, columns)
			pMap.put(Tag.Rows.tagName, rows)
			
			//NOTE: because of dicoogle bug, uri's must be just with one slash -> / 
			pMap.put('uri', '''file:/«serie.study.patient.pid»/«uid».dcm''')
		]
	}
	
	def static findByUID(String uid) {
		Image.find.query.where.eq('uid', uid).findUnique
	}
}