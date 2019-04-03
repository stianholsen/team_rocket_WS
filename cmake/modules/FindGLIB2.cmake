#
# - Try to find the GLIB2 libraries
# Once done this will define
#
#  GLIB2_FOUND        - system has glib2
#  GLIB2_INCLUDE_DIRS - the glib2 include directory
#  GLIB2_LIBRARIES    - glib2 library
#  GLIB2_DLL_DIR      - (Windows) Path to required GLib2 DLLs.
#  GLIB2_DLLS         - (Windows) List of required GLib2 DLLs.

# Copyright (c) 2008 Laurent Montel, <montel@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.


if( GLIB2_MAIN_INCLUDE_DIR AND GLIB2_LIBRARIES )
	# Already in cache, be silent
	set( GLIB2_FIND_QUIETLY TRUE )
endif()

include( FindWSWinLibs )
FindWSWinLibs( "vcpkg-export-*" "GLIB2_HINTS" )

if (NOT WIN32)
	find_package(PkgConfig)

	if( GLIB2_MIN_VERSION )
		pkg_search_module( GLIB2 glib-2.0>=${GLIB2_MIN_VERSION} )
	else()
		pkg_search_module( GLIB2 glib-2.0 )
	endif()
endif()

find_path( GLIB2_MAIN_INCLUDE_DIR
	NAMES
		glib.h
	HINTS
		"${GLIB2_INCLUDEDIR}"
		"${GLIB2_HINTS}/include"
	PATH_SUFFIXES
		glib-2.0
		glib-2.0/include
	PATHS
		/opt/gnome/include
		/opt/local/include
		/sw/include
		/usr/include
		/usr/local/include
)

find_library( GLIB2_LIBRARY
	NAMES
		glib-2.0
		libglib-2.0
	HINTS
		"${GLIB2_LIBDIR}"
		"${GLIB2_HINTS}/lib"
	PATHS
		/opt/gnome/lib64
		/opt/gnome/lib
		/opt/lib/
		/opt/local/lib
		/sw/lib/
		/usr/lib64
		/usr/lib
)

# search the glibconfig.h include dir under the same root where the library is found
get_filename_component( glib2LibDir "${GLIB2_LIBRARY}" PATH)

find_path( GLIB2_INTERNAL_INCLUDE_DIR
	NAMES
		glibconfig.h
	HINTS
		"${GLIB2_INCLUDEDIR}"
		"${GLIB2_HINTS}/include"
		"${glib2LibDir}"
		${CMAKE_SYSTEM_LIBRARY_PATH}
	PATH_SUFFIXES
		glib-2.0/include
	PATHS
		${GLIB2_LIBRARY}

)

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( GLIB2
	DEFAULT_MSG
	GLIB2_LIBRARY
	GLIB2_MAIN_INCLUDE_DIR
)

if( GLIB2_FOUND )
	set( GLIB2_LIBRARIES ${GLIB2_LIBRARY} )
	# Include transitive dependencies for static linking.
	if(UNIX AND CMAKE_FIND_LIBRARY_SUFFIXES STREQUAL ".a")
		find_library(PCRE_LIBRARY pcre)
		list(APPEND GLIB2_LIBRARIES -pthread ${PCRE_LIBRARY})
	endif()
	set( GLIB2_INCLUDE_DIRS ${GLIB2_MAIN_INCLUDE_DIR} ${GLIB2_INTERNAL_INCLUDE_DIR} )
	if ( WIN32 AND GLIB2_FOUND )
		set ( GLIB2_DLL_DIR "${GLIB2_HINTS}/bin"
			CACHE PATH "Path to GLib2 DLLs"
		)
		# GTK+ required GObject and GIO. We probably don't.
		file( GLOB _glib2_dlls RELATIVE "${GLIB2_DLL_DIR}"
			# "${GLIB2_DLL_DIR}/gio-2.dll"
			"${GLIB2_DLL_DIR}/glib-2.dll"
			"${GLIB2_DLL_DIR}/gmodule-2.dll"
			# "${GLIB2_DLL_DIR}/gobject-2.dll"
			"${GLIB2_DLL_DIR}/gthread-2.dll"
			"${GLIB2_DLL_DIR}/libcharset.dll"
			# gnutls-3.6.3-1-win64ws ships with libffi-6.dll
			# "${GLIB2_DLL_DIR}/libffi.dll"
			"${GLIB2_DLL_DIR}/libiconv.dll"
			"${GLIB2_DLL_DIR}/libintl.dll"
			"${GLIB2_DLL_DIR}/pcre.dll"
			# "${GLIB2_DLL_DIR}/pcre16.dll"
			# "${GLIB2_DLL_DIR}/pcre32.dll"
			# "${GLIB2_DLL_DIR}/pcrecpp.dll"
			# "${GLIB2_DLL_DIR}/pcreposix.dll"
		)
		set ( GLIB2_DLLS ${_glib2_dlls}
			# We're storing filenames only. Should we use STRING instead?
			CACHE FILEPATH "GLib 2 DLL list"
		)

		file( GLOB _glib2_pdbs RELATIVE "${GLIB2_DLL_DIR}"
			"${GLIB2_DLL_DIR}/glib-2.pdb"
			"${GLIB2_DLL_DIR}/gmodule-2.pdb"
			"${GLIB2_DLL_DIR}/gthread-2.pdb"
			"${GLIB2_DLL_DIR}/libcharset.pdb"
			"${GLIB2_DLL_DIR}/libiconv.pdb"
			"${GLIB2_DLL_DIR}/libintl.pdb"
			"${GLIB2_DLL_DIR}/pcre.pdb"
		)
		set ( GLIB2_PDBS ${_glib2_pdbs}
			CACHE FILEPATH "GLib2 PDB list"
		)

		mark_as_advanced( GLIB2_DLL_DIR GLIB2_DLLS GLIB2_PDBS )
	endif()
elseif( GLIB2_FIND_REQUIRED )
	message( SEND_ERROR "Package required but not found" )
else()
	set( GLIB2_LIBRARIES )
	set( GLIB2_MAIN_INCLUDE_DIRS )
	set( GLIB2_DLL_DIR )
	set( GLIB2_DLLS )
endif()

mark_as_advanced( GLIB2_INCLUDE_DIRS GLIB2_LIBRARIES )
