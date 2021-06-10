GridRefine
===============
Copyright 2021 Cadence Design Systems, Inc. All rights reserved worldwide.

This script allows users to automatically generate a family of grids from a baseline mesh for the purposes of a grid refinement study. The user need only specify a refinement factor, the baseline grid file name, and whether any existing unstructured blocks should be initialized. These parameters are changed by editing the script file.

The user specified refinement factor modifies connectors, domains, and blocks. More specifically, it refines:

* Connector spacing and dimension
* Domain min or max triangle edge length
* Diagonalized structured domains
* T-Rex wall initial spacing

Run either interactively or from the command line, it provides progress information and even additional block diagnostics, assuming block initialization was turned on. When the script finishes, the refined surface and volume grids are saved to the current working directory.

Note: A refinement factor of 1 or lower will abort the script. However, this script can be used to initialize large unstructured blocks in batch mode by setting refinementFactor = 1 and volMesh = "YES".

Disclaimer
----------
This file is licensed under the Cadence Public License Version 1.0 (the "License"), a copy of which is found in the LICENSE file, and is distributed "AS IS." 
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE. 
Please see the License for the full text of applicable terms.
	 

