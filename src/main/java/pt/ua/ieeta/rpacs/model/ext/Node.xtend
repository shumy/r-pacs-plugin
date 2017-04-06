package pt.ua.ieeta.rpacs.model.ext

import com.avaje.ebean.annotation.DbJsonB
import java.util.Map
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity
import javax.persistence.Table
import javax.persistence.UniqueConstraint

@XEntity
@Table(uniqueConstraints = #[
	@UniqueConstraint(columnNames = #["type_id", "annotation_id"])
])
class Node {
	
	@ManyToOne
	@NotNull NodeType type
	
	@ManyToOne
	@NotNull Annotation annotation
	
	@DbJsonB
	Map<String, Object> fields
}