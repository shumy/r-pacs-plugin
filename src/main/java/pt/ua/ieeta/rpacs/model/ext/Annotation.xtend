package pt.ua.ieeta.rpacs.model.ext

import java.util.List
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity
import javax.persistence.Table
import javax.persistence.UniqueConstraint

@XEntity
@Table(uniqueConstraints = #[
	@UniqueConstraint(columnNames = #["image_id", "annotator_id"])
])
class Annotation {
	@NotNull AnnotationStatus status
	
	@ManyToOne
	@NotNull Image image
	
	@ManyToOne
	@NotNull Annotator annotator
	
	@OneToMany(mappedBy = "annotation", cascade = ALL)
	List<Node> nodes
}

enum AnnotationStatus { PARTIAL, COMPLETE }