package pt.ua.ieeta.rpacs

import java.net.URI
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.QueryInterface
import pt.ua.dicoogle.sdk.datastructs.SearchResult
import pt.ua.ieeta.rpacs.utils.DocSearch
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase
import pt.ua.ieeta.rpacs.model.Image

class RPacsQuery extends RPacsPluginBase implements QueryInterface {
	static val logger = LoggerFactory.getLogger(RPacsQuery)
	
	@Accessors val name = 'r-pacs-query'
	
	override query(String qText, Object... parameters) {
		queryText(qText)
	}
	
	def queryText(String qText) {
		logger.info('QUERY - {}', qText)
		val results = findImages(qText).map[
			val hMap = toFlatDicom as HashMap<String, Object>
			new SearchResult(new URI(uri), 1, hMap)
		]
		
		logger.info('QUERY-RESULTS-COUNT - {}', results.size)
		return results
	}
	
	private def findImages(String qText) {
		if (qText.startsWith('SOPInstanceUID:')){
			val keyValue = qText.split(':')
			return newArrayList(Image.findByUID(keyValue.get(1)))
		}
		
		DocSearch.search(qText, 0, 100)
	}
}