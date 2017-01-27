package pt.ua.ieeta.rpacs

import java.net.URI
import java.util.HashMap
import org.dcm4che2.data.Tag
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.QueryInterface
import pt.ua.dicoogle.sdk.datastructs.SearchResult
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

class RPacsQuery extends RPacsPluginBase implements QueryInterface {
	static val logger = LoggerFactory.getLogger(RPacsQuery)
	
	@Accessors val name = 'r-pacs-query'
	val URI location
	
	val dicTranslate = #{
		Tag.PatientID.tagName 					-> 'serie.study.patient.pid',
		Tag.PatientName.tagName 				-> 'serie.study.patient.name',
		Tag.PatientSex.tagName 					-> 'serie.study.patient.sex',
		Tag.PatientBirthDate.tagName 			-> 'serie.study.patient.birthdate', //TODO: value conversion
		Tag.PatientAge.tagName 					-> 'serie.study.patient.age',
		
		Tag.StudyInstanceUID.tagName 			-> 'serie.study.uid',
		Tag.StudyID.tagName 					-> 'serie.study.sid',
		Tag.AccessionNumber.tagName 			-> 'serie.study.accessionNumber',
		Tag.StudyDescription.tagName 			-> 'serie.study.description',
		Tag.StudyDate.tagName 					-> 'serie.study.datetime', //TODO: value conversion
		Tag.StudyTime.tagName 					-> 'serie.study.datetime', //TODO: value conversion
		Tag.InstitutionName.tagName 			-> 'serie.study.institutionName',
		Tag.InstitutionAddress.tagName 			-> 'serie.study.institutionAddress',
		
		Tag.SeriesInstanceUID.tagName 			-> 'serie.uid',
		Tag.SeriesNumber.tagName 				-> 'serie.number',
		Tag.SeriesDescription.tagName 			-> 'serie.description',
		Tag.SeriesDate.tagName 					-> 'serie.datetime', //TODO: value conversion
		Tag.SeriesTime.tagName 					-> 'serie.datetime', //TODO: value conversion
		Tag.Modality.tagName 					-> 'serie.modality',
		
		Tag.SOPInstanceUID.tagName 				-> 'uid',
		Tag.InstanceNumber.tagName 				-> 'number',
		Tag.PhotometricInterpretation.tagName 	-> 'photometric',
		Tag.Columns.tagName 					-> 'columns',
		Tag.Rows.tagName 						-> 'rows',
		Tag.Laterality.tagName 					-> 'laterality'
	}
	
	new(String url) { this.location = new URI(url) }
	
	override query(String qText, Object... parameters) {
		queryText(qText)
	}
	
	def queryText(String qText) {
		logger.info('QUERY - {}', qText)
		val results = findPatients(qText).map[
			val hMap = toFlatDicom as HashMap<String, Object>
			new SearchResult(new URI(uri), 1, hMap)
		]
		
		logger.info('QUERY-RESULTS-COUNT - {}', results.size)
		return results
	}
	
	private def translate(String field) {
		dicTranslate.get(field) ?: field
	}
	
	private def findPatients(String qText) {
		var pWhere = Image.find.query
			.setDisableLazyLoading(true)
			.fetch('serie')
			.fetch('serie.study')
			.fetch('serie.study.patient')
			.where
		
		// <field>:<value> [and <field>:<value>]*
		for(it: qText.split('and')) {
			val fieldAndValue = split(':')
			if (fieldAndValue.length === 2) {
				val field = fieldAndValue.get(0).trim.translate
				val value = fieldAndValue.get(1).trim
				pWhere = pWhere.contains(field, value)
			}
		}
		
		return pWhere.findList
	}
}