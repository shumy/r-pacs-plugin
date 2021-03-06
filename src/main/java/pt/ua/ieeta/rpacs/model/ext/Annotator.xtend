package pt.ua.ieeta.rpacs.model.ext

import com.avaje.ebean.Ebean
import com.avaje.ebean.annotation.Index
import java.util.ArrayList
import java.util.List
import java.util.UUID
import javax.persistence.Column
import javax.persistence.ManyToMany
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity

@XEntity
class Annotator {
	
	@Index
	@Column(unique=true)
	@NotNull String name
	
	//anonymized annotator identification
	@NotNull String alias
	
	@ManyToOne
	Dataset currentDataset
	
	@ManyToMany(mappedBy = "annotators")
	List<Dataset> datasets
	
	def Pointer getOrPreCreatePointer(NodeType nType) {
		Pointer.find.query.where
			.eq('type', nType)
			.eq('dataset', currentDataset)
			.eq('annotator', this)
		.findUnique ?: (new Pointer => [
			dataset = currentDataset
			annotator = this
			type = nType
			last = -1L
			next = 0L
		])
	}
	
	def static Annotator getOrCreateAnnotator(String username) {
		Annotator.find.query.where.eq('name', username).findUnique ?: Ebean.execute[
			new Annotator() => [
				name = username
				alias = UUID.randomUUID.toString
				currentDataset = Dataset.findDefault
				datasets = new ArrayList<Dataset>(1)
				datasets.add(currentDataset)
				save
			]
		]
	}
}