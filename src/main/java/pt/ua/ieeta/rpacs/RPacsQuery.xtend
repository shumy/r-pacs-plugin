package pt.ua.ieeta.rpacs

import java.net.URI
import java.util.ArrayList
import org.dcm4che2.data.Tag
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.QueryInterface
import pt.ua.dicoogle.sdk.datastructs.SearchResult
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*

class RPacsQuery extends RPacsPluginBase implements QueryInterface {
	static val logger = LoggerFactory.getLogger(RPacsQuery)
	
	@Accessors val name = 'r-pacs-query'
	val URI location
	
	val dicTranslate = #{
		Tag.PatientID.tagName 					-> 'pid',
		Tag.PatientName.tagName 				-> 'name',
		Tag.PatientSex.tagName 					-> 'sex',
		Tag.PatientBirthDate.tagName 			-> 'birthdate', //TODO: value conversion
		Tag.PatientAge.tagName 					-> 'age',
		
		Tag.StudyInstanceUID.tagName 			-> 'studies.uid',
		Tag.StudyID.tagName 					-> 'studies.sid',
		Tag.AccessionNumber.tagName 			-> 'studies.accessionNumber',
		Tag.StudyDescription.tagName 			-> 'studies.description',
		Tag.StudyDate.tagName 					-> 'studies.datetime', //TODO: value conversion
		Tag.StudyTime.tagName 					-> 'studies.datetime', //TODO: value conversion
		Tag.InstitutionName.tagName 			-> 'studies.institutionName',
		Tag.InstitutionAddress.tagName 			-> 'studies.institutionAddress',
		
		Tag.SeriesInstanceUID.tagName 			-> 'studies.series.uid',
		Tag.SeriesNumber.tagName 				-> 'studies.series.number',
		Tag.SeriesDescription.tagName 			-> 'studies.series.description',
		Tag.SeriesDate.tagName 					-> 'studies.series.datetime', //TODO: value conversion
		Tag.SeriesTime.tagName 					-> 'studies.series.datetime', //TODO: value conversion
		Tag.Modality.tagName 					-> 'studies.series.modality',
		
		Tag.SOPInstanceUID.tagName 				-> 'studies.series.images.uid',
		Tag.InstanceNumber.tagName 				-> 'studies.series.images.number',
		Tag.PhotometricInterpretation.tagName 	-> 'studies.series.images.photometric',
		Tag.Columns.tagName 					-> 'studies.series.images.columns',
		Tag.Rows.tagName 						-> 'studies.series.images.rows',
		Tag.Laterality.tagName 					-> 'studies.series.images.laterality'
	}
	
	def translate(String field) { dicTranslate.get(field) ?: field }
	
	new(String url) { this.location = new URI(url) }
	
	override query(String qText, Object... parameters) {
		logger.info('QUERY - {}', qText)
		queryText(qText)
	}
	
	def queryText(String qText) {
		val results = new ArrayList<SearchResult>
		findPatients(qText).forEach[
			toFlatDicom.forEach[
				val uri = new URI(get('uri').toString)
				results.add(new SearchResult(uri, 1, it))
			]
		]
		
		logger.info('QUERY-RESULTS-COUNT - {}', results.size)
		return results
	}
	
	def findPatients(String qText) {
		var pWhere = Patient.find.query
			.setDisableLazyLoading(true)
			.fetch('studies')
			.fetch('studies.series')
			.fetch('studies.series.images')
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