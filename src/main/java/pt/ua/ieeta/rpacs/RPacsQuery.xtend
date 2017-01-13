package pt.ua.ieeta.rpacs

import java.net.URI
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.QueryInterface
import pt.ua.dicoogle.sdk.datastructs.SearchResult
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase

class RPacsQuery extends RPacsPluginBase implements QueryInterface {
	static val logger = LoggerFactory.getLogger(RPacsQuery)
	
	@Accessors val name = 'r-pacs-query'
	val URI location
	
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
				val field = fieldAndValue.get(0).trim
				val value = fieldAndValue.get(1).trim
				pWhere = pWhere.contains(field, value)
			}
		}
		
		return pWhere.findList
	}
}