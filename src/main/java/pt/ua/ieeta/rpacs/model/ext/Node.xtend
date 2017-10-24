package pt.ua.ieeta.rpacs.model.ext

import com.avaje.ebean.Model
import com.avaje.ebean.annotation.CreatedTimestamp
import com.avaje.ebean.annotation.DbJsonB
import com.avaje.ebean.annotation.SoftDelete
import com.avaje.ebean.annotation.UpdatedTimestamp
import com.fasterxml.jackson.annotation.JsonProperty
import java.time.LocalDateTime
import java.util.Map
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.UniqueConstraint
import javax.persistence.Version
import javax.validation.constraints.NotNull
import shy.xhelper.data.gen.GenAccessors
import shy.xhelper.ebean.IEntity
import shy.xhelper.ebean.json.gen.GenJson
import com.avaje.ebean.Finder

//@XEntity
@Entity
@GenJson
@GenAccessors
@Table(uniqueConstraints = #[
	@UniqueConstraint(columnNames = #["type_id", "annotation_id"])
])
class Node extends Model implements IEntity {
	public final static Finder<Long, Node> find = new Finder(Node)
	
	@Id
	Long id
	
	@Version
	@JsonProperty(access=READ_ONLY)
	Long version
	
	@SoftDelete
	Boolean deleted = false
	
	@CreatedTimestamp
	LocalDateTime createdAt
	
	@UpdatedTimestamp
	LocalDateTime updatedAt
	
	@ManyToOne
	@NotNull NodeType type
	
	@ManyToOne
	@NotNull Annotation annotation
	
	@DbJsonB
	Map<String, Object> fields
}