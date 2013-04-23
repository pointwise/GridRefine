GridRefine
===============
This script allows users to automatically generate a family of grids from a baseline mesh for the purposes of a grid refinement study. The user need only specify a refinement factor, the baseline grid file name, and whether any existing unstructured blocks should be initialized. These parameters are changed by editing the script file.

The user specified refinement factor modifies connectors, domains, and blocks. More specifically, it refines:

* Connector spacing and dimension
* Domain min or max triangle edge length
* T-Rex wall initial spacing

Run either interactively or from the command line, it provides progress information and even additional block diagnostics, assuming block initialization was turned on. When the script finishes, the refined surface and volume grids are saved to the current working directory.

Note: A refinement factor of 1 or lower will abort the script. However, this script can be used to initialize large unstructured blocks in batch mode by setting refinementFactor = 1 and volMesh = "YES".

Disclaimer
----------
Scripts are freely provided. They are not supported products of
Pointwise, Inc. Some scripts have been written and contributed by third
parties outside of Pointwise's control.

TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, WITH REGARD TO THESE SCRIPTS. TO THE MAXIMUM EXTENT PERMITTED
BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS
INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR
INABILITY TO USE THESE SCRIPTS EVEN IF POINTWISE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE FAULT OR NEGLIGENCE OF
POINTWISE.
	 

