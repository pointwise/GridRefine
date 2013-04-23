#
# Copyright 2012 (c) Pointwise, Inc.
# All rights reserved.
# 
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.  
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

# ==================================================================================================
# GRID REFINEMENT SCRIPT - POINTWISE
# ==================================================================================================
# Written by Travis Carrigan
#
# v1: Apr 27, 2011
# v2: May 03, 2011
# v3: May 13, 2011
# v4: Oct 12, 2011
# v5: Oct 13, 2011
# v6: Oct 21, 2011
#


# -------------------------------------
# User Defined Parameters
# -------------------------------------
# Refinement factor
set refinementFactor 2

# Pointwise file name, please include .pw file extension
set pwFile "TestGrid.pw"

# Whether to create volume mesh, YES or NO
set volMesh "YES"



###############################################################
#-- MAIN
#--
#-- Main script body.
#--
###############################################################
# Start timer
set startTime [clock seconds]

# Load Glyph package
package require PWI_Glyph

# Setup Pointwise and define working directory
pw::Application reset
pw::Application clearModified
set cwd [file dirname [info script]]

# Output Pointwise version information
puts ""
puts "[pw::Application getVersion]"
puts ""
puts "Refinement factor is set to $refinementFactor"
puts ""

# Check if refinement factor is greater than 1
if {$refinementFactor <= 1} {

    if {$volMesh == "YES"} {

        # Load Pointwise file
        pw::Application load [file join $cwd $pwFile]

        # Save surface mesh
        set fileRoot [file rootname $pwFile]
        set fileExport "$fileRoot-Surface-$refinementFactor.pw"

        puts ""
        puts "Writing $fileExport file..."
        puts ""
        pw::Application save [file join $cwd $fileExport]
        
        # Gather all blocks
        set blkList [pw::Grid getAll -type pw::Block]

        # Gather all unstructured blocks
        set unsBlkList [pw::Grid getAll -type pw::BlockUnstructured]

        puts ""
        puts "Initializing volume mesh..."
        puts ""
        
        # Start timer
        set volStartTime [clock seconds]

        # Initialize unstructured blocks
        set blkMode [pw::Application begin UnstructuredSolver $unsBlkList]            
            
            $blkMode run Initialize
            $blkMode end
        
        unset blkMode

        # End timer
        set volEndTime [clock seconds]

	    # Print block information
	    foreach blk $blkList {
	
	        if {[$blk isOfType "pw::BlockStructured"]} {
	
	            puts ""
	            puts "Block [$blk getName]"
	            puts "--------------------"
	            puts "Block Type: Structured"
	            puts "Total Cell Count: [$blk getCellCount]"
	            puts ""
	
	        } elseif {[$blk isOfType "pw::BlockUnstructured"]} {
	
	            puts ""
	            puts "Block [$blk getName]"
	            puts "--------------------"
	            puts "Block Type: Unstructured"
	
	            if {[$blk getTRexCellCount]>0} {
	
	                puts "Full TRex Layers:  [$blk getTRexFullLayerCount]"
	                puts "Total TRex Layers: [$blk getTRexTotalLayerCount]"
	                puts "Total TRex Cells:  [$blk getTRexCellCount]"
	                puts "Total Cell Count:  [$blk getCellCount]"
	                puts ""
	
	            } else {
	
	                puts "Total Cell Count: [$blk getCellCount]"
	
	            }
	
	        } elseif {[$blk isOfType "pw::BlockExtruded"]} {
	
	            puts ""
	            puts "Block [$blk getName]"
	            puts "--------------------"
	            puts "Block Type: Extruded"
	            puts "Total Cell Count: [$blk getCellCount]"
	            puts ""
	
	        } else {
	
	            puts ""
	            puts "Block [$blk getName] type not supported by this script."
	            puts ""
	
	        }
	
	    }

        # Save volume mesh
        set fileExport "$fileRoot-Volume-$refinementFactor.pw"

        puts ""
        puts "Writing $fileExport file..."
        puts "Volume initialization completed in [expr {$volEndTime-$volStartTime}] seconds"
        puts ""
        pw::Application save [file join $cwd $fileExport]

        # End timer
        set endTime [clock seconds]

        puts ""
        puts "Pointwise script executed in [expr $endTime-$startTime] seconds"
        puts ""

        exit

    } else {

        puts ""
        puts "Refinement factor is 1 or lower, nothing to do..."
        puts ""
   
        exit

    }

}

# Load Pointwise file
pw::Application load [file join $cwd $pwFile] 

# Start timer
set surfStartTime [clock seconds]

# Gather all connectors
set conList [pw::Grid getAll -type pw::Connector]

# Gather all domains
set domList [pw::Grid getAll -type pw::Domain]

# Gather all blocks
set blkList [pw::Grid getAll -type pw::Block]

# Gather all unstructured blocks
set unsBlkList [pw::Grid getAll -type pw::BlockUnstructured]

# Loop through all connectors
set conCount 0

set conMode [pw::Application begin Modify $conList]

   foreach con $conList {
   
      # Progress information
      incr conCount
      puts ""
      puts "Refining connector $conCount of [llength $conList]..."
      puts "      ...connector [$con getName]"
      puts ""
      
      # Get connector distribution type
      set conDist [$con getDistribution 1]
      
      # Check if distribution is of type growth
      if {[$conDist isOfType "pw::DistributionGrowth"]} {
      
         # Decrease grid point spacing
         $conDist setBeginSpacing [expr {(1.0/$refinementFactor)*[[$conDist getBeginSpacing] getValue]}]
         $conDist setEndSpacing   [expr {(1.0/$refinementFactor)*[[$conDist getEndSpacing] getValue]}]
         
         # Set optimal connector dimension
         $con setDimensionFromDistribution
      
      } else {
      
         # Increase connector dimension in 3 steps ...
         # 1) Store refined subconnector dimensions
         set totalDim 0
         for {set i 1} {$i <= [$con getSubConnectorCount]} {incr i} {
            set dim [expr {round($refinementFactor*[$con getSubConnectorDimension $i]-1)}]
            lappend conSubDim $dim
            set totalDim [expr {$dim+$totalDim}]
         }

         # 2) Redimension connector
         $con setDimension [expr {$totalDim-([$con getSubConnectorCount]-1)}]

         # 3) Adjust subconnector dimension
         if {[$con getSubConnectorCount] > 1} {
            $con setSubConnectorDimension $conSubDim
         }
         unset conSubDim

         # Decrease grid point spacing 
         for {set i 1} {$i <= [$con getSubConnectorCount]} {incr i} {
            set conDist [$con getDistribution $i]
            $conDist setBeginSpacing [expr (1.0/$refinementFactor)*[[$conDist getBeginSpacing] getValue]]
            $conDist setEndSpacing   [expr (1.0/$refinementFactor)*[[$conDist getEndSpacing] getValue]]
         }
   
   }

}
$conMode end
unset conMode

# Get list of TRex condition names
set trexCondsNames [pw::TRexCondition getNames]

# Loop through all TRex condition names
foreach trexCondsName $trexCondsNames {
		
	# Get TRex condition object from name
	lappend trexConds [pw::TRexCondition getByName $trexCondsName]

}

# If conditions exist, loop through all conditions
if {[llength $trexConds]>0} {

	foreach trex $trexConds {
		
		# If condition is of type wall adjust spacing
		if {[$trex getType]=="Wall"} {

			# Get spacing
			set trexSpc [$trex getSpacing]

			# Refine initial step height
			set newSpc [expr (1.0/$refinementFactor)*$trexSpc]

			# Set new spacing
			$trex setSpacing $newSpc

		}

	}

}

# Loop through all domains
set domCount 0

foreach dom $domList {

	# Progress information
	incr domCount
	puts ""
	puts "Refining domain $domCount of [llength $domList]..."
	puts "      ...domain [$dom getName]"
	puts ""

	if {[$dom isOfType "pw::DomainUnstructured"]} {

        # Refine interior triangles if necessary
        set domMinEdgeLen [$dom getUnstructuredSolverAttribute EdgeMinimumLength]
        set domMaxEdgeLen [$dom getUnstructuredSolverAttribute EdgeMaximumLength]

        if {$domMinEdgeLen != "Boundary"} {
            $dom setUnstructuredSolverAttribute EdgeMinimumLength [expr {$domMinEdgeLen/$refinementFactor}]
        }

        if {$domMaxEdgeLen != "Boundary"} {
            $dom setUnstructuredSolverAttribute EdgeMaximumLength [expr {$domMaxEdgeLen/$refinementFactor}]
        }

		set unsSolver [pw::Application begin UnstructuredSolver $dom]
	    
            if [catch {$unsSolver run Refine}] {
                lappend domError [$dom getName]
		        $unsSolver end
                continue
            }
		
        $unsSolver end
	
	}

}

# Write out domains that were not refined
if {[info exists domError]} {

    puts "Error refining [llength $domError] domains:"
    
    foreach dom $domError {
        puts "$dom"
    }

}

# Save surface mesh
set fileRoot [file rootname $pwFile]
set fileExport "$fileRoot-Surface-$refinementFactor.pw"

# End timer
set surfEndTime [clock seconds]

puts ""
puts "Writing $fileExport file..."
puts "Surface refinement completed in [expr {$surfEndTime-$surfStartTime}] seconds"
puts ""
pw::Application save [file join $cwd $fileExport]

if {$volMesh == "YES"} {

    puts ""
    puts "Initializing volume mesh..."
    puts ""

    # Start timer
    set volStartTime [clock seconds]

    # Initialize unstructured blocks
    set blkMode [pw::Application begin UnstructuredSolver $unsBlkList]            
            
        $blkMode run Initialize
        $blkMode end
        
    unset blkMode
    
    # End timer
    set volEndTime [clock seconds]

    # Print block information
	foreach blk $blkList {
	
	    if {[$blk isOfType "pw::BlockStructured"]} {
	
	        puts ""
	        puts "Block [$blk getName]"
	        puts "--------------------"
	        puts "Block Type: Structured"
	        puts "Total Cell Count: [$blk getCellCount]"
	        puts ""
	
	    } elseif {[$blk isOfType "pw::BlockUnstructured"]} {
	
	        puts ""
	        puts "Block [$blk getName]"
	        puts "--------------------"
	        puts "Block Type: Unstructured"
	
	        if {[$blk getTRexCellCount]>0} {
	
	            puts "Full TRex Layers:  [$blk getTRexFullLayerCount]"
	            puts "Total TRex Layers: [$blk getTRexTotalLayerCount]"
	            puts "Total TRex Cells:  [$blk getTRexCellCount]"
	            puts "Total Cell Count:  [$blk getCellCount]"
	            puts ""
	
	        } else {
	
	            puts "Total Cell Count: [$blk getCellCount]"
	
	        }
	
	    } elseif {[$blk isOfType "pw::BlockExtruded"]} {
	
	        puts ""
	        puts "Block [$blk getName]"
	        puts "--------------------"
	        puts "Block Type: Extruded"
	        puts "Total Cell Count: [$blk getCellCount]"
	        puts ""
	
	    } else {
	
	        puts ""
	        puts "Block [$blk getName] type not supported by this script."
	        puts ""
	
	    }
	
	}

    # Save volume mesh
    set fileExport "$fileRoot-Volume-$refinementFactor.pw"

    puts ""
    puts "Writing $fileExport file..."
    puts "Volume initialization completed in [expr {$volEndTime-$volStartTime}] seconds"
    puts ""
    pw::Application save [file join $cwd $fileExport]

} 

# End timer
set endTime [clock seconds]

puts ""
puts "Pointwise script executed in [expr $endTime-$startTime] seconds"
puts ""



# 
# END SCRIPT
#

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED 
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY 
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES 
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE 
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE 
# FAULT OR NEGLIGENCE OF POINTWISE.
#
