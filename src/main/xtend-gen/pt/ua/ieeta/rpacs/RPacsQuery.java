package pt.ua.ieeta.rpacs;

import com.avaje.ebean.ExpressionList;
import com.avaje.ebean.Query;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import pt.ua.dicoogle.sdk.QueryInterface;
import pt.ua.dicoogle.sdk.datastructs.SearchResult;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase;

@SuppressWarnings("all")
public class RPacsQuery extends RPacsPluginBase implements QueryInterface {
  private final static Logger logger = LoggerFactory.getLogger(RPacsQuery.class);
  
  @Accessors
  private final String name = "r-pacs-query";
  
  private final URI location;
  
  public RPacsQuery(final String url) {
    try {
      URI _uRI = new URI(url);
      this.location = _uRI;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Override
  public Iterable<SearchResult> query(final String qText, final Object... parameters) {
    ArrayList<SearchResult> _xblockexpression = null;
    {
      RPacsQuery.logger.info("QUERY - {}", qText);
      _xblockexpression = this.queryText(qText);
    }
    return _xblockexpression;
  }
  
  public ArrayList<SearchResult> queryText(final String qText) {
    final ArrayList<SearchResult> results = new ArrayList<SearchResult>();
    List<Patient> _findPatients = this.findPatients(qText);
    final Consumer<Patient> _function = (Patient it) -> {
      List<HashMap<String, Object>> _flatDicom = it.toFlatDicom();
      final Consumer<HashMap<String, Object>> _function_1 = (HashMap<String, Object> it_1) -> {
        try {
          Object _get = it_1.get("uri");
          String _string = _get.toString();
          final URI uri = new URI(_string);
          SearchResult _searchResult = new SearchResult(uri, 1, it_1);
          results.add(_searchResult);
        } catch (Throwable _e) {
          throw Exceptions.sneakyThrow(_e);
        }
      };
      _flatDicom.forEach(_function_1);
    };
    _findPatients.forEach(_function);
    int _size = results.size();
    RPacsQuery.logger.info("QUERY-RESULTS-COUNT - {}", Integer.valueOf(_size));
    return results;
  }
  
  public List<Patient> findPatients(final String qText) {
    Query<Patient> _query = Patient.find.query();
    Query<Patient> _setDisableLazyLoading = _query.setDisableLazyLoading(true);
    Query<Patient> _fetch = _setDisableLazyLoading.fetch("studies");
    Query<Patient> _fetch_1 = _fetch.fetch("studies.series");
    Query<Patient> _fetch_2 = _fetch_1.fetch("studies.series.images");
    ExpressionList<Patient> pWhere = _fetch_2.where();
    String[] _split = qText.split("and");
    for (final String it : _split) {
      {
        final String[] fieldAndValue = it.split(":");
        int _length = fieldAndValue.length;
        boolean _tripleEquals = (_length == 2);
        if (_tripleEquals) {
          String _get = fieldAndValue[0];
          final String field = _get.trim();
          String _get_1 = fieldAndValue[1];
          final String value = _get_1.trim();
          ExpressionList<Patient> _contains = pWhere.contains(field, value);
          pWhere = _contains;
        }
      }
    }
    return pWhere.findList();
  }
  
  @Pure
  public String getName() {
    return this.name;
  }
}
