package pt.ua.ieeta.rpacs.model.ext

import shy.xhelper.ebean.XEntity
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import javax.persistence.Table
import javax.persistence.UniqueConstraint

@XEntity
@Table(uniqueConstraints = #[
	@UniqueConstraint(columnNames = #["dataset_id", "annotator_id", "type_id"])
])
class Pointer {
	@ManyToOne
	@NotNull Dataset dataset
	
	@ManyToOne
	@NotNull Annotator annotator
	
	@ManyToOne
	@NotNull NodeType type
	
	//last image in the dataset annotated with this node type
	@NotNull Long last
	
	//next image to annotate in the dataset, this can be dislocated with several processes, inclusively manually by the physician
	@NotNull Long next
}