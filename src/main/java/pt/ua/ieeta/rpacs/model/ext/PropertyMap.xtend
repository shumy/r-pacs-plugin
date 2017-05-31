package pt.ua.ieeta.rpacs.model.ext

import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity
import com.avaje.ebean.annotation.Index

@XEntity
class PropertyMap {
	@Index
	@NotNull String key
	
	@NotNull String value
	
	def static allOfKey(String key) {
		PropertyMap.find.query.where.eq('key', key).findList
	}
}