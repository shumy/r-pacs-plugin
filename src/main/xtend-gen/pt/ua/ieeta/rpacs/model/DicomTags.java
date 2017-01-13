package pt.ua.ieeta.rpacs.model;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.HashMap;
import org.dcm4che2.data.Tag;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class DicomTags {
  private final static HashMap<Integer, String> map = ObjectExtensions.<HashMap<Integer, String>>operator_doubleArrow(new HashMap<Integer, String>(), ((Procedure1<HashMap<Integer, String>>) (HashMap<Integer, String> it) -> {
    try {
      Field[] _declaredFields = Tag.class.getDeclaredFields();
      final Function1<Field, Boolean> _function = (Field it_1) -> {
        return Boolean.valueOf(((Modifier.isStatic(it_1.getModifiers()) && Modifier.isFinal(it_1.getModifiers())) && Modifier.isPublic(it_1.getModifiers())));
      };
      final Iterable<Field> tagFields = IterableExtensions.<Field>filter(((Iterable<Field>)Conversions.doWrapArray(_declaredFields)), _function);
      for (final Field field : tagFields) {
        int _int = field.getInt(null);
        String _name = field.getName();
        it.put(Integer.valueOf(_int), _name);
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }));
  
  public static String tagName(final int tag) {
    return DicomTags.map.get(Integer.valueOf(tag));
  }
}
