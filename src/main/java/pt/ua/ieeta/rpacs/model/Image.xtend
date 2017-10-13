package pt.ua.ieeta.rpacs.model

import com.avaje.ebean.Ebean
import com.avaje.ebean.RawSqlBuilder
import com.avaje.ebean.annotation.DocEmbedded
import com.avaje.ebean.annotation.DocProperty
import com.avaje.ebean.annotation.DocStore
import com.avaje.ebean.annotation.Index
import java.util.HashMap
import java.util.List
import java.util.Map
import javax.persistence.Column
import javax.persistence.ManyToMany
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import org.dcm4che2.data.Tag
import pt.ua.ieeta.rpacs.model.ext.Annotation
import pt.ua.ieeta.rpacs.model.ext.Dataset
import shy.xhelper.ebean.XEntity

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

@XEntity
@DocStore(indexName = Image.INDEX)
class Image {
	public static val INDEX = 'r_pacs_image'
	
	@DocEmbedded(doc = 'id,uid,number,description,datetime,modality,stationName,manufacturer,manufacturerModelName,study(id,uid,sid,accessionNumber,description,datetime,institutionName,institutionAddress,patient(id,pid,name,sex,birthdate))')
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
	
	@DocProperty(enabled = false)
	@NotNull String uri
	
	@DocEmbedded(doc = 'name')
	@ManyToMany(mappedBy = "images")
	List<Dataset> datasets
	
	@DocEmbedded(doc = 'id,annotator(alias),nodes(id,type(name), fields)')
	@OneToMany(mappedBy = "image", cascade = ALL)
	List<Annotation> annotations
	
	def getSequence(Dataset ds) {
		val query = Ebean.createSqlQuery('''
			select seq from (select row_number() over() - 1 as seq, image_id as image from dataset_image where dataset_id = «ds.id») as dataset
			where image = «id»;
		''')
		
		return query.findUnique.getInteger('seq')
	}
	
	def Map<String, Object> toFlatDicom() {
		new HashMap<String, Object> => [
			put(Tag.SOPInstanceUID.tagName, uid)
			put(Tag.InstanceNumber.tagName, number)
			put(Tag.PhotometricInterpretation.tagName, photometric)
			put(Tag.Columns.tagName, columns)
			put(Tag.Rows.tagName, rows)
			put(Tag.Laterality.tagName, laterality)
			put('uri', uri)
			
			putAll(serie.toFlatDicom)
		]
	}
	
	def static findByUID(String uid) {
		Image.find.query.where.eq('uid', uid).findUnique
	}
	
	def static getImageRefs(Dataset ds, Integer offset, Integer limit) {
		val sql = '''
			select image_id as id, (select uid from image where id = image_id) as uid from dataset_image
			where dataset_id = «ds.id»
			offset «offset» limit «limit»;
		'''
		
		val query = Ebean.find(Image) => [
			rawSql = RawSqlBuilder.parse(sql).create
		]
		
		return query.findList
	}
}