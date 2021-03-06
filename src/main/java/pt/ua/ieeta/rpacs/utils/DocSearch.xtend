package pt.ua.ieeta.rpacs.utils

import java.util.Collections
import java.util.LinkedList
import java.util.List
import java.util.regex.Pattern
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import org.dcm4che2.data.Tag
import pt.ua.ieeta.rpacs.model.Image

import static extension pt.ua.ieeta.rpacs.model.DicomTags.*
import org.apache.commons.lang.StringUtils

class DocSearch {
	public static val JSON = MediaType.parse("application/json; charset=utf-8")
	
	public static val mappings = #{
		Tag.PatientID.tagName.toLowerCase 					-> 'serie.study.patient.pid',
		Tag.PatientName.tagName.toLowerCase 				-> 'serie.study.patient.name',
		Tag.PatientSex.tagName.toLowerCase 					-> 'serie.study.patient.sex',
		Tag.PatientBirthDate.tagName.toLowerCase 			-> 'serie.study.patient.birthdate',
		Tag.PatientAge.tagName.toLowerCase 					-> 'serie.study.patient.age',
		
		Tag.StudyInstanceUID.tagName.toLowerCase 			-> 'serie.study.uid',
		Tag.StudyID.tagName.toLowerCase 					-> 'serie.study.sid',
		Tag.AccessionNumber.tagName.toLowerCase 			-> 'serie.study.accessionNumber',
		Tag.StudyDescription.tagName.toLowerCase 			-> 'serie.study.description',
		Tag.StudyDate.tagName.toLowerCase 					-> 'serie.study.datetime',
		Tag.StudyTime.tagName.toLowerCase 					-> 'serie.study.datetime',
		Tag.InstitutionName.tagName.toLowerCase 			-> 'serie.study.institutionName',
		Tag.InstitutionAddress.tagName.toLowerCase 			-> 'serie.study.institutionAddress',
		
		Tag.SeriesInstanceUID.tagName.toLowerCase 			-> 'serie.uid',
		Tag.SeriesNumber.tagName.toLowerCase 				-> 'serie.number',
		Tag.SeriesDescription.tagName.toLowerCase 			-> 'serie.description',
		Tag.SeriesDate.tagName.toLowerCase 					-> 'serie.datetime',
		Tag.SeriesTime.tagName.toLowerCase 					-> 'serie.datetime',
		
		Tag.Modality.tagName.toLowerCase 					-> 'serie.modality',
		Tag.StationName.tagName.toLowerCase 				-> 'serie.stationName',
		Tag.Manufacturer.tagName.toLowerCase 				-> 'serie.manufacturer',
		Tag.ManufacturerModelName.tagName.toLowerCase 		-> 'serie.manufacturerModelName',
		
		Tag.SOPInstanceUID.tagName.toLowerCase 				-> 'uid',
		Tag.InstanceNumber.tagName.toLowerCase 				-> 'number',
		Tag.PhotometricInterpretation.tagName.toLowerCase 	-> 'photometric',
		Tag.Columns.tagName.toLowerCase 					-> 'columns',
		Tag.Rows.tagName.toLowerCase 						-> 'rows',
		Tag.Laterality.tagName.toLowerCase 					-> 'laterality',
		
		//annotations
		'annotation' 										-> 'annotations.nodes.type.name',
		'annotator'											-> 'annotations.annotator.alias',
		//'field' 											-> 'annotations.nodes.fields',
		
		//search ui alias
		'image'												-> 'uid',
		'datetime'											-> 'serie.datetime',
		
		'birthdate'											-> 'serie.study.patient.birthdate',
		'sex'												-> 'serie.study.patient.sex',
		
		'createdat'											-> 'annotations.nodes.createdAt',
		'nodetype'											-> 'annotations.nodes.type.name',
		'readability'										-> 'annotations.nodes.fields.quality',
		'centered'											-> 'annotations.nodes.fields.local',
		'retinopathy'										-> 'annotations.nodes.fields.retinopathy',
		'maculopathy'										-> 'annotations.nodes.fields.maculopathy',
		'photocoagulation'									-> 'annotations.nodes.fields.photocoagulation',
		'comorbidities'										-> 'annotations.nodes.fields.diseases',
		'lesions' 											-> 'annotations.nodes.fields.lesions.type',
		
		'dataset'											-> 'datasets.name'
	}
	
	def static List<Image> search(String qText, int from, int size) {
		val lowerSearch = qText.toLowerCase
		
		val searchText = dimDecode(lowerSearch)
		println('''SEARCH-DECODED: "«lowerSearch»" -> "«searchText»"''')
		
		val results = try {
			val images = post('http://localhost:9200/' + Image.INDEX + '/image/_search', '''{
				"from": «from», "size": «IF size === 0»«10000»«ELSE»«size»«ENDIF»,
				"sort": ["_doc"],
				"stored_fields": [ "_id" ],
				"query": {
					"query_string": {
						"query": "«searchText»",
						"analyzer": "standard"
					}
				}
			}''')
			
			if (images.size !== 0)
				Image.find.query
					//.setDisableLazyLoading(true)
					.fetch('serie')
					.fetch('serie.study')
					.fetch('serie.study.patient')
					.fetch('annotations.nodes')
				.where.idIn(images).findList
			else
				Collections.EMPTY_LIST
		} catch (Throwable ex) {
			println('SEARCH-ERROR: ' + ex.message)
			Collections.EMPTY_LIST
		}
		
		println('SEARCH-RESULTS: ' + results.size)
		return results
	}
	
	def static dimDecode(String lowerSearch) {
		val query = lowerSearch.replaceAll('\\[([0-9]{4})([0-9]{2})([0-9]{2}) to ([0-9]{4})([0-9]{2})([0-9]{2})\\]', '[$1-$2-$3 TO $4-$5-$6]')
		
		val pattern = Pattern.compile('(\\w+)\\s*:')
		val matcher = pattern.matcher(query)
		
		var int last = 0
		val sb = new StringBuilder
		while (matcher.find) {
			val field = matcher.group(1)
			val replacer = mappings.get(field) ?: field
			println('''DECODE: «field» -> «replacer»''')
			
			sb.append(query.substring(last, matcher.start(1)))
			sb.append(replacer)
			
			last = matcher.end(1)
		}
		sb.append(query.substring(last, query.length))
		
		return StringUtils.replaceEach(sb.toString, #[' to ', ' and ', ' or '], #[' TO ', ' AND ', ' OR '])
	}
	
	def static post(String url, String json) {
		val client = new OkHttpClient
		
		val body = RequestBody.create(JSON, json)
		val request = new Request.Builder().url(url).post(body).build
		val response = client.newCall(request).execute
		val rJson = response.body.string
		
		//can't use jackson because of dicoogle incompatible versions!!!
		val p = Pattern.compile('\"_id\":\\s*\"([0-9]*)\"')
		val m = p.matcher(rJson)
		
		val ids = new LinkedList<String>
		while(m.find) {
			val id = m.group(1)
			ids.add(id)
		}
		
		return ids
	}
}