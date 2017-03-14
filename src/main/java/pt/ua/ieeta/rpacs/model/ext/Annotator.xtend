package pt.ua.ieeta.rpacs.model.ext

import com.avaje.ebean.annotation.Index
import java.util.List
import javax.persistence.Column
import javax.persistence.ManyToMany
import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity
import javax.persistence.OneToOne

@XEntity
class Annotator {
	
	@Index
	@Column(unique=true)
	@NotNull String name
	
	//anonymized annotator identification
	@NotNull String alias
	
	@OneToOne
	Dataset currentDataset
	
	@ManyToMany(mappedBy = "annotators")
	List<Dataset> dataset
	
	def static findByName(String name) {
		Annotator.find.query.where.eq('name', name).findUnique
	}
}