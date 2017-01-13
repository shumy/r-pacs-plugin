package pt.ua.ieeta.rpacs.model

import java.util.HashMap
import org.dcm4che2.data.Tag
import java.lang.reflect.Modifier

class DicomTags {
	static val map = new HashMap<Integer, String> => [
		val tagFields = Tag.declaredFields.filter[ Modifier.isStatic(modifiers) && Modifier.isFinal(modifiers) &&  Modifier.isPublic(modifiers) ]
		for(field: tagFields)
			put(field.getInt(null), field.name)
	]
	
	public static def tagName(int tag) { return map.get(tag) }
}