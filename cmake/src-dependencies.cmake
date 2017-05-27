if(BUILD_TESTING)
  # want GTEST_ADD_TESTS() macro. NOT THE ACTUAL MODULE!
  include(GTEST_ADD_TESTS)

  # for the actual gtest:

  # at least in debian, they are the package only installs their source code,
  # so if one wants to use them, he needs to compile them in-tree
  include(GoogleTest)

  add_dependencies(dependencies gtest gmock_main)
endif()

if(BUILD_BENCHMARKING)
  include(GoogleBenchmark)

  add_dependencies(dependencies benchmark)
endif()

if(WITH_PTHREADS)
  message(STATUS "Looking for PThreads")
  set(CMAKE_THREAD_PREFER_PTHREAD 1)
  find_package(Threads REQUIRED)
  if(NOT CMAKE_USE_PTHREADS_INIT)
    message(SEND_ERROR "Did not found POSIX Threads! Either make it find PThreads, or pass -DWITH_PTHREADS=OFF to disable threading.")
  else()
    message(STATUS "Looking for PThreads - found")
    set(HAVE_PTHREAD 1)
  endif()
else()
  message(STATUS "PThread-based threading is disabled. Not searching for PThreads")
endif()

if(WITH_OPENMP)
  message(STATUS "Looking for OpenMP")
  find_package(OpenMP)
  if(OPENMP_FOUND)
    message(STATUS "Looking for OpenMP - found")
  else()
    message(WARNING "Looking for OpenMP - failed. utilities will not use openmp-based parallelization")
  endif()
else()
  message(STATUS "OpenMP is disabled, utilities will not use openmp-based parallelization")
endif()

if(WITH_PUGIXML)
  message(STATUS "Looking for pugixml")
  if(NOT USE_BUNDLED_PUGIXML)
    find_package(Pugixml 1.2)
    if(NOT Pugixml_FOUND)
      message(SEND_ERROR "Did not found Pugixml! Either make it find Pugixml, or pass -DUSE_BUNDLED_PUGIXML=ON to enable in-tree pugixml.")
    else()
      message(STATUS "Looking for pugixml - found (system)")
    endif()
  else()
    include(Pugixml)
    if(NOT Pugixml_FOUND)
      message(SEND_ERROR "Managed to fail to use 'bundled' Pugixml!")
    else()
      message(STATUS "Looking for pugixml - found ('in-tree')")
      add_dependencies(dependencies ${Pugixml_LIBRARIES})
    endif()
  endif()

  if(Pugixml_FOUND)
    set(HAVE_PUGIXML 1)
    include_directories(SYSTEM ${Pugixml_INCLUDE_DIRS})
  endif()
endif()

if(WITH_JPEG)
  message(STATUS "Looking for JPEG")
  find_package(JPEG REQUIRED)
  if(NOT JPEG_FOUND)
    message(SEND_ERROR "Did not find JPEG! Either make it find JPEG, or pass -DWITH_JPEG=OFF to disable JPEG.")
  else()
    message(STATUS "Looking for JPEG - found")
    include_directories(SYSTEM ${JPEG_INCLUDE_DIRS})
    set(HAVE_JPEG 1)

    include(CheckJPEGSymbols)
  endif()
else()
  message(STATUS "JPEG is disabled, DNG Lossy JPEG support won't be available.")
endif()

if (WITH_ZLIB)
  message(STATUS "Looking for ZLIB")
  if(NOT USE_BUNDLED_ZLIB)
    find_package(ZLIB)
    if(NOT ZLIB_FOUND)
      message(SEND_ERROR "Did not find ZLIB! Either make it find ZLIB, or pass -DWITH_ZLIB=OFF to disable ZLIB, or pass -DUSE_BUNDLED_ZLIB=ON to enable in-tree ZLIB.")
    else()
      message(STATUS "Looking for ZLIB - found (system)")
      include_directories(SYSTEM ${ZLIB_INCLUDE_DIRS})
    endif()
  else()
    include(Zlib)
    if(NOT ZLIB_FOUND)
      message(SEND_ERROR "Managed to fail to use 'bundled' ZLIB!")
    else()
      message(STATUS "Looking for ZLIB - found ('in-tree')")
      add_dependencies(dependencies ${ZLIB_LIBRARIES})
    endif()
  endif()

  if(ZLIB_FOUND)
    set(HAVE_ZLIB 1)
  endif()
else()
  message(STATUS "ZLIB is disabled, DNG deflate support won't be available.")
endif()
