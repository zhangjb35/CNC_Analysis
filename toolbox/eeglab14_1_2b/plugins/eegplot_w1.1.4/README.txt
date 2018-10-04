This EEGLAB plugin provides eegplot_w() and pop_eegplot_w(), 
that are almost identical to eegplot() and pop_eegplot(), but allow 
scroll with mouse wheel, looks better in wide-screen monitor,
draw EEG data faster and allows to remove channels / components 
(with Shift+click at EEG data line).

Keyboard shortcuts:
PageUp   - move to left without overlaping
Left     - move to left by 1/5 of window
Right    - move to right by 1/5 of window
PageDown - move to right without overlaping
Ctrl+Up  - increase visible time window
Ctrl+Down- decrease visible time window
Alt+Up   - increase scale
Alt+Down - decrease scale

--

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
--
 
v1.1.3 2017-03-27
  Fixed support for MATLAB R2015 and older versions.
v1.1.4 2017-04-20
  Removed no longer working Zoom from function from menu.
 
(C) 2017 Mindaugas Baranauskas
