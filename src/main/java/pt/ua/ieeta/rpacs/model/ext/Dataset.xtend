package pt.ua.ieeta.rpacs.model.ext

import java.util.List
import javax.persistence.Column
import javax.persistence.ManyToMany
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity
import javax.persistence.OneToMany

@XEntity
class Dataset {
	
	@Column(columnDefinition = "boolean default false not null")
	Boolean isDefault = false
	
	@Column(unique=true)
	@NotNull String name
	
	@ManyToMany
	List<Image> images
	
	@ManyToMany
	List<Annotator> annotators
	
	@OneToMany(mappedBy = "dataset", cascade = ALL)
	List<Pointer> pointers
	
	def static findDefault() {
		Dataset.find.query.where.eq('isDefault', true).findUnique
	}
}