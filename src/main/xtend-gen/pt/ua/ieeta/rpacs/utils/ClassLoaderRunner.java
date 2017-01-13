package pt.ua.ieeta.rpacs.utils;

import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;

@SuppressWarnings("all")
public class ClassLoaderRunner {
  public static void runWith(final ClassLoader classLoader, final Procedure0 clousure) {
    Thread _currentThread = Thread.currentThread();
    final ClassLoader ctx = _currentThread.getContextClassLoader();
    try {
      Thread _currentThread_1 = Thread.currentThread();
      _currentThread_1.setContextClassLoader(classLoader);
      clousure.apply();
    } catch (final Throwable _t) {
      if (_t instanceof Throwable) {
        final Throwable ex = (Throwable)_t;
        ex.printStackTrace();
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    } finally {
      Thread _currentThread_2 = Thread.currentThread();
      _currentThread_2.setContextClassLoader(ctx);
    }
  }
  
  public static void runWith(final Class<?> loaderFromClass, final Procedure0 clousure) {
    ClassLoader _classLoader = loaderFromClass.getClassLoader();
    ClassLoaderRunner.runWith(_classLoader, clousure);
  }
}
