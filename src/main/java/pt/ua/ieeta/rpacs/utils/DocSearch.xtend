package pt.ua.ieeta.rpacs.utils

import com.fasterxml.jackson.databind.ObjectMapper
import java.util.Collections
import java.util.HashMap
import java.util.List
import java.util.Map
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import pt.ua.ieeta.rpacs.model.Image

class DocSearch {
	public static val JSON = MediaType.parse("application/json; charset=utf-8")
	
	def static List<Image> search(String searchText, int from, int size) {
		/*val fields = parse(searchText)
		if (fields.size === 0)
			return Collections.EMPTY_LIST
		
		var ExpressionList<Image> express = Ebean.defaultServer.find(Image).text.must
		for (field: fields.keySet)
			express = express.match(field, fields.get(field))
		
		express.findList*/
		
		val tree = post('http://localhost:9200/_search', '''{
			"from": «from», "size": «size»,
			"stored_fields": [ "_type", "_id" ],
			"query": {
				"query_string": {
					"query": "«searchText»"
				}
			}
		}''')
		
		val hits = tree.get('hits')
		val images = hits.get('hits').filter[ get('_type').asText == 'image' ].map[ get('_id').asLong ].toList
		return Image.find.query.where.idIn(images)
			.findList
	}
	
	def static Map<String, String> parse(String qText) {
		val map = new HashMap<String, String>
		// <field>:<value> [and <field>:<value>]*
		for(it: qText.split('and')) {
			val fieldAndValue = split(':')
			if (fieldAndValue.length === 2) {
				val field = fieldAndValue.get(0).trim
				val value = fieldAndValue.get(1).trim
				map.put(field, value)
			} else {
				println('QUERY-NON-VALID')
				return Collections.EMPTY_MAP
			}
		}
		
		return map
	}
	
	def static post(String url, String json) {
		val client = new OkHttpClient
		
		val body = RequestBody.create(JSON, json)
		val request = new Request.Builder().url(url).post(body).build
		val response = client.newCall(request).execute
		val rJson = response.body.string
		
		val mapper = new ObjectMapper
		return mapper.readTree(rJson)
	}
}