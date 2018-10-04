% eegplugin_eegplot_w() 
%    Provides eegplot_w() and pop_eegplot_w(), that are almost identical
%    to eegplot() and pop_eegplot(), but allow scroll with mouse wheel, 
%    to remove channels / components (with Shift+click), 
%    looks better in wide-screen monitor and draw EEG data faster.
% 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
% Si programa yra laisva. Jus galite ja platinti ir/arba modifikuoti
% remdamiesi Free Software Foundation paskelbtomis GNU Bendrosios
% Viesosios licencijos salygomis: 2 licencijos versija, arba (savo
% nuoziura) bet kuria velesne versija.
%
% Si programa platinama su viltimi, kad ji bus naudinga, bet BE JOKIOS
% GARANTIJOS; be jokios numanomos PERKAMUMO ar TINKAMUMO KONKRETIEMS
% TIKSLAMS garantijos. Ziurekite GNU Bendraja Viesaja licencija noredami
% suzinoti smulkmenas.
%
% Jus turejote kartu su sia programa gauti ir GNU Bendrosios Viesosios
% licencijos kopija; jei ne - rasykite Free Software Foundation, Inc., 59
% Temple Place - Suite 330, Boston, MA 02111-1307, USA.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% (C) 2017 Mindaugas Baranauskas   
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vers = eegplugin_eegplot_w(fig, trystrs, catchstrs)
vers='eegplot_w1.1.3';
% Menu
menu = findobj(fig, 'tag', 'plot');
comm = [trystrs.check_data 'LASTCOM = pop_eegplot_w(EEG, 1, 1, 1); ' catchstrs.add_to_hist ] ;
uimenu( menu, 'label', 'Channel data (scroll) +', 'Separator','off', ...
       'userdata', 'startup:off;study:off', 'Callback', comm,...
       'position',3);
