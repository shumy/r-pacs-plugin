package pt.ua.ieeta.rpacs.model.ext

import com.avaje.ebean.annotation.Index
import javax.persistence.Column
import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity

@XEntity
class Annotator {
	
	@Index
	@Column(unique=true)
	@NotNull String name
	
	@NotNull String alias
	
	def static findByName(String name) {
		Annotator.find.query.where.eq('name', name).findUnique
	}
}