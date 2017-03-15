package pt.ua.ieeta.rpacs.model.ext

import java.util.List
import javax.persistence.Column
import javax.persistence.ManyToMany
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity

@XEntity
class Dataset {
	
	@Column(columnDefinition = "boolean default false not null")
	Boolean isDefault = false
	
	@NotNull String name
	
	@ManyToMany
	List<Image> images
	
	@ManyToMany
	List<Annotator> annotators
	
	def static findDefault() {
		Dataset.find.query.where.eq('isDefault', true).findUnique
	}
}