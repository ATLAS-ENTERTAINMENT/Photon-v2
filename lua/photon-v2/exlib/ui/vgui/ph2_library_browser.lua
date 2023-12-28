local class = "Photon2UILibraryBrowser"
local base = "Photon2UIWindow"
local description = "Photon 2 Library Asset Browser"
local PANEL = {}

PANEL.AllowAutoRefresh = true

local padding = 8
local margin = 8

local printf = Photon2.Debug.PrintF
local print = Photon2.Debug.Print

PANEL.ColumnSchema = {
	{
		Label = "Name",
		Property = "Name",
		Search = true
	},
	{
		Label = "Title",
		Property = "Title",
		Search = true
	},
	{
		Label = "Author",
		Property = "Author",
		Search = true
	},
	{
		Label = "Source",
		Property = "SourceType"
	}
}

function PANEL:SetSearchFilter( value )
	if ( value == "" ) then
		self.SearchFilter = false
	else
		self.SearchFilter = string.lower( value )
	end
	self:PopulateEntries()
end

function PANEL:SetSourceFilter( source )
	if ( not source ) then
		self.SourceFilter = false
	else
		self.SourceFilter = source
	end
	self:PopulateEntries()
end

function PANEL:SetupTopControls()
	local this = self
	local panel = vgui.Create( "DPanel", self )
	panel:DockMargin( -4, -4, -4, 0 )
	panel:Dock( TOP )
	panel:SetHeight( 72 )
	panel:SetPaintBackground( false )
	this.TopControls = panel

	local divider = vgui.Create( "EXDHorizontalDivider", panel )
	divider:Dock( FILL )
	divider:SetAnchor("R")

	local searchPanel = vgui.Create( "DPanel", panel )
	searchPanel:DockPadding( 0, padding, padding, padding )
	searchPanel:SetPaintBackground( false )
	divider:SetRight( searchPanel )

	
	local searchTextBox = vgui.Create( "EXDTextEntry", searchPanel )
	searchTextBox:Dock( FILL )
	searchTextBox:SetPlaceholderText( " Search" )
	searchTextBox:SetUpdateOnType( true )
	function searchTextBox:OnValueChange( value )
		this:SetSearchFilter( value )	
	end

	local pathPanel = vgui.Create( "DPanel", panel )
	pathPanel:DockPadding( padding, padding, 0, padding )
	pathPanel:SetPaintBackground( false )
	divider:SetLeft( pathPanel )

	local pathTextBox = vgui.Create( "EXDTextEntry", pathPanel )
	pathTextBox:Dock( FILL )
	pathTextBox:SetText( "library/" .. tostring( self.CurrentLibrary.Folder ) )
	pathTextBox:SetEnabled( false )
	searchTextBox:SetTextInset( 16, 16 )

	-- Photon2.Util.PrintTableProperties( pathTextBox )

	local actions = vgui.Create( "EXDActionBar", panel )
	actions.Placement = "Span"
	actions:Dock( BOTTOM )
	this.ActionBar = actions
end

function PANEL:SetupMain()
	local this = self

	local main = vgui.Create( "DPanel", this )
	main:SetPaintBackground( false )
	main:Dock( FILL )
	main:DockMargin( margin-4, margin, margin-4, margin )

	local divider = vgui.Create( "EXDHorizontalDivider", main )
	divider:Dock( FILL )
	divider:SetAnchor("R")

	local browserPanel = vgui.Create( "DPanel", main )
	browserPanel:SetPaintBackground( false )
	divider:SetLeft( browserPanel )

	local files = vgui.Create( "EXDListView", browserPanel )
	files:Dock( FILL )

	for i, schema in ipairs( self.ColumnSchema ) do
		files:AddColumn( schema.Label )
	end

	files:SetMultiSelect( false )

	function files:OnRowSelected( lineId, line )
		this:SetSelected( line.EntryName )
	end

	function files:DoDoubleClick( lineId, line )
		this:OnItemDoubleClick( line.EntryName )
	end

	this.EntriesPanel = files

	local previewPanel = vgui.Create( "DPanel", main )
	divider:SetRight( previewPanel )

	self.MainPanel = main
end

function PANEL:OnItemDoubleClick( value )
	self:OnFileConfirmed( value )
end

function PANEL:PopulateEntries()
	local files = self.EntriesPanel
	if ( not IsValid( files ) ) then return end
	files:Clear()



	for name, entry in pairs( self.CurrentLibrary.Repository ) do
		
		if ( self.SearchFilter ) then
			local column, propertyValue
			local pass = false
			for i=1, #self.ColumnSchema do
				column = self.ColumnSchema[i]
				if ( not column.Search ) then continue end
				propertyValue = string.lower( entry[column.Property] or "" )
				local startPos, endPos, match = string.find(propertyValue, self.SearchFilter, nil, true )
				-- printf("[%s] ~ [%s] => [%s]", propertyValue, self.SearchFilter, tostring( startPos ~= nil ) )
				if ( startPos ~= nil ) then
					pass = true
					break
				end
			end
			if ( not pass ) then continue end
		end

		if ( self.SourceFilter ) then
			if ( entry.SourceType ~= self.SourceFilter ) then
				continue
			end
		end

		local columns = {}
		for i=1, #self.ColumnSchema do
			columns[i] = entry[self.ColumnSchema[i].Property]
		end

		
		local line = files:AddLine( unpack( columns ) )
		line.EntryName = name
		if ( name == self.SelectedEntryName ) then
			files:SelectItem( line )
		end
		if ( self.FileMode =="SAVE" and entry.ReadOnly ) then
			line.LineDisabled = true
			line:SetMouseInputEnabled( false )
			line:SetEnabled( false )
		end
	end

end

-- Checks if an "open" operation on an entry should succeed.
function PANEL:VerifyOpenEntry( value )
	if ( value == nil or value == "" ) then return false end
	if ( not self.CurrentLibrary.Repository[value] ) then
		Photon2.UI.DialogBox.UserError( tostring( value ) .. "\nEntry could not be found.\nPlease check the name and try again." )
		return false
	end
	return true
end

function PANEL:AttemptSave( value )
	local this = self
	if ( value == nil or value == "" ) then return false end
	if ( self.CurrentLibrary.Repository[value] ) then
		local entry = self.CurrentLibrary.Repository[value]
		if ( entry.ReadOnly ) then
			Photon2.UI.DialogBox.UserError( value .. " is read-only and cannot be overwritten." )
		else
			Photon2.UI.DialogBox.Confirm(
				-- title
				"Confirm Save As",
				-- message
				string.format("%s already exists.\nDo you want to replace it?", value),
				-- onYes
				function() this:OnFileConfirmed( value, false ) end,
				-- onNo
				nil
			)
		end
		
	else
		self:OnFileConfirmed( value, false )
	end
end

function PANEL:AttemptSelect( value )
	if ( not self:VerifyOpenEntry( value ) ) then return end
	self:OnFileConfirmed( value, false )
end

function PANEL:AttemptOpen( value )
	local this = self
	if ( not self:VerifyOpenEntry( value ) ) then return end
	local entry = self.CurrentLibrary.Repository[value]
	if ( entry.ReadOnly ) then
		Photon2.UI.DialogBox.OpenReadOnly( 
			value,
			function() self:OnFileConfirmed( value, false ) end,
			function() self:AttemptOpenAsCopy( value) end,
			nil
		)
	else
		self:OnFileConfirmed( value, false )
	end
end

function PANEL:AttemptOpenAsCopy( value )
	if ( not self:VerifyOpenEntry( value ) ) then return end
	self:OnFileConfirmed( value, true )
end

function PANEL:SetupBottom()
	local this = self
	
	local bottom = vgui.Create( "DPanel", this )
	bottom:SetPaintBackground( false )
	bottom:Dock( BOTTOM )
	bottom:SetHeight( 62 )
	bottom:DockPadding( 4, 0, 4, 4)

	local top = vgui.Create( "DPanel", bottom )
	top:SetPaintBackground( false )
	top:Dock( TOP )
	top:SetHeight( 26 )

	local typeLabel = vgui.Create( "DLabel", top )
	typeLabel:SetText( "Name:" )
	typeLabel:Dock( LEFT )
	typeLabel:SetTextInset( 8, 0 )

	local fileName = vgui.Create( "EXDTextEntry", top )
	fileName:Dock( FILL )
	fileName:DockMargin( 8, 0, 8, 0 )
	this.FileNameTextBox = fileName
	this.FileNameTextBox:RequestFocus()


	local usedTypes = self.CurrentLibrary:GetUsedSourceTypes()

	local fileType = vgui.Create( "DComboBox", top )
	fileType:SetWidth( 128 )
	fileType:Dock( RIGHT )
	local fileTypeAll = fileType:AddChoice( "All Sources" )
	fileType:ChooseOptionID( 1 )
	for key, value in pairs( usedTypes ) do
		fileType:AddChoice( key, key )
	end

	function fileType:OnSelect( index, value, data )
		this:SetSourceFilter( data )
	end

	local buttons = vgui.Create( "DPanel", bottom )
	buttons:Dock( BOTTOM )
	buttons:SetHeight( 24 )
	buttons:SetPaintBackground( false )

	local cancelButton = vgui.Create( "EXDButton", buttons )
	cancelButton:SetText( "Cancel" )
	cancelButton:SetWidth( 92 )
	cancelButton:Dock( RIGHT )
	cancelButton:DockMargin( 8, 0, 0, 0 )
	
	local confirmButton = vgui.Create( "EXDButton", buttons )
	confirmButton:SetText( "Select" )
	confirmButton:SetWidth( 92 )
	confirmButton:Dock( RIGHT )
	confirmButton:DockMargin( 8, 0, 0, 0 )

	

	function cancelButton:DoClick()
		this:OnCanceled()
	end

	if ( self.FileMode == "OPEN" ) then
		confirmButton:SetText( "Open" )
		local openCopy = vgui.Create( "EXDButton", buttons )
		openCopy:SetText( "Open as Copy" )
		openCopy:SetWidth( 92 )
		openCopy:Dock( RIGHT )
		function confirmButton:DoClick()
			this:AttemptOpen( this.FileNameTextBox:GetText() )
		end
		function openCopy:DoClick()
			this:AttemptOpenAsCopy( this.FileNameTextBox:GetText() )
		end
	elseif ( self.FileMode == "SAVE" ) then		
		confirmButton:SetText( "Save" )
		function confirmButton:DoClick()
			this:AttemptSave( this.FileNameTextBox:GetText() )
		end
		this.OnItemDoubleClick = this.AttemptSave
	else
		confirmButton:SetText( "Select" )
		function confirmButton:DoClick()
			this:AttemptSelect( this.FileNameTextBox:GetText() )
		end
		cancelButton:SetText( "Close" )
	end

	self.BottomPanel = bottom
end

function PANEL:SetSelected( entryName )
	self.SelectedEntryName = entryName
	local entry = self.CurrentLibrary:Get( entryName )
	self.SelectedEntry = entry
	self.FileNameTextBox:SetText( entryName )
end

-- Override
function PANEL:OnFileConfirmed( entryName, copy )
	print( "File confirmed: " .. tostring( entryName ) )
	self:Close()
end

function PANEL:OnCanceled()
	self:Close()
end

function PANEL:Init()
	self.BaseClass.Init( self )
	local this = self
end

---@param library string Library type.
---@param mode "OPEN" | "SAVE" | "SELECT" Mode type.
function PANEL:Setup( library, mode )
	local this = self
	self:SetWidth( 500 )
	self:SetHeight( 380 )
	self:Center()
	---@type PhotonLibraryType
	self.CurrentLibrary = Photon2.Library[library]

	if ( not self.CurrentLibrary ) then
		ErrorNoHaltWithStack( "Invalid library type [" .. tostring( library ) .. "]." )
		this:Remove()
	end

	local title = "Browse"

	if ( mode == "OPEN" ) then
		title = "Open "
	elseif ( mode == "SAVE" ) then
		title = "Save "
	elseif ( mode == "SELECT") then
		title = "Select "
	end

	self.FileMode = mode

	title = title .. self.CurrentLibrary.Singular .. "..."

	self:SetTitle( title )
	
	self:SetupTopControls()
	self:SetupMain()
	self:SetupBottom()

	self:PopulateEntries()

	self:MakePopup()
end

-- Sets the file selection text box to the given value and selects the text.
-- Used for standardized save-as behavior.
function PANEL:PreFillSelection( name )
	self.FileNameTextBox:SetText( name )
	self.FileNameTextBox:RequestFocus()
	self.FileNameTextBox:SelectAll(true)
	self.FileNameTextBox:SetCaretPos( string.len(name) )
end

function PANEL:PostAutoRefresh()
	if ( self.TopControls ) then self.TopControls:Remove() end
	if ( self.MainPanel ) then self.MainPanel:Remove() end
	if ( self.BottomPanel ) then self.BottomPanel:Remove() end
	self:Setup( "InputConfigurations", "OPEN" )
end

derma.DefineControl( class, description, PANEL, base )