import Foundation

/// Labels/order observed through the running OneNote 16.114.1 accessibility UI.
/// No notebook titles, account details, document bodies or proprietary artwork.
public struct InterfaceItem: Sendable, Equatable {
    public let title: String
    public let children: [InterfaceItem]
    public init(_ title: String, _ children: [InterfaceItem] = []) { self.title = title; self.children = children }
    public static let separator = InterfaceItem("-")
}

public enum InterfaceCatalog {
    private static func items(_ names: [String]) -> [InterfaceItem] { names.map { InterfaceItem($0) } }
    public static let styles = (1...6).map { "Heading \($0)" } + ["Page Title", "Citation", "Quote", "Code", "Normal"]
    public static let tags = ["To Do", "Important", "Question", "Remember for later", "Definition", "Love it", "Looks good", "Critical", "tick", "chosen", "slack"]
    public static let shapes = ["Line", "Arrow", "Double Arrow", "Elbow", "Elbow Arrow", "Elbow Double Arrow", "Rectangle", "Oval", "Triangle", "Parallelogram", "Diamond", "2 dimensions, positive", "2 dimensions, full", "3 dimensions"]
    public static let paperStyles = ["None", "Narrow Ruled", "College Ruled", "Standard Ruled", "Wide Ruled", "Small Grid", "Medium Grid", "Large Grid", "Very Large Grid"]
    public static let menus: [InterfaceItem] = [
        InterfaceItem("OpenOneNote", [InterfaceItem("About OpenOneNote"), InterfaceItem("Preferences…"), InterfaceItem("Install OneNote Clipper…"), InterfaceItem("Sign Out…"), .separator, InterfaceItem("Services"), .separator, InterfaceItem("Hide OpenOneNote"), InterfaceItem("Hide Others"), InterfaceItem("Show All"), .separator, InterfaceItem("Quit OpenOneNote"), InterfaceItem("Quit and Keep Windows")]),
        InterfaceItem("File", items(["New Page", "New Section", "New Section Group", "New Notebook…"]) + [.separator] + items(["Open Notebook…", "Open Recent…", "Open Backups", "Open Section…"]) + [.separator] + items(["Sync This Notebook", "Sync All Notebooks"]) + [.separator, InterfaceItem("Close This Notebook"), .separator, InterfaceItem("Quick Look"), .separator, InterfaceItem("Share", items(["Send Link to Notebook…", "Copy Link to Notebook…", "Manage Notebook Access…", "Send Page as Email Message", "Send Page as PDF"])), InterfaceItem("Save as PDF"), .separator, InterfaceItem("Close"), .separator, InterfaceItem("Print…")]),
        InterfaceItem("Edit", items(["Undo", "Redo"]) + [.separator] + items(["Cut", "Copy", "Paste", "Paste and Match Formatting", "Paste and Keep Text Only", "Clear All Formatting", "Delete", "Select All", "Select Current Page"]) + [.separator, InterfaceItem("Find", items(["Search This Page", "Search This Section", "Search This Section Group", "Search This Notebook", "Search All Notebooks", "Find Next", "Find Previous"])), InterfaceItem("AutoFill", items(["Contact…", "Passwords…", "Credit Card…"])), .separator, InterfaceItem("Start Dictation…"), InterfaceItem("Emoji & Symbols")]),
        InterfaceItem("View", [InterfaceItem("Ribbon"), InterfaceItem("Hide Section and Page Lists"), InterfaceItem("Switch Background"), InterfaceItem("Paper Style", [InterfaceItem("Rule Lines")] + items(Array(paperStyles.prefix(5))) + [.separator, InterfaceItem("Grid Lines")] + items(Array(paperStyles.suffix(4))) + [.separator, InterfaceItem("Always Create Pages with Rule Lines")]), InterfaceItem("Hide Page Title"), .separator] + items(["Zoom In", "Zoom Out", "Reset Zoom", "Zoom to Page Width"]) + [.separator, InterfaceItem("Hide Authors"), .separator] + items(["Increase Navigation Pane Width", "Decrease Navigation Pane Width", "Enter Full Screen"])),
        InterfaceItem("Insert", items(["Table", "File…", "Printout…", "Picture…"]) + [.separator] + items(["Date", "Date & Time", "Link…", "Equation"]) + [InterfaceItem("Shape", items(shapes)), .separator] + items(["Audio Recording", "Meeting Details…", "Stickers…"])),
        InterfaceItem("Format", [InterfaceItem("Styles", items(styles)), .separator] + items(["Bold", "Italic", "Underline", "Strikethrough", "Highlight", "Subscript", "Superscript", "Copy Format", "Paste Format"]) + [.separator] + items(["Bulletpoints", "Numbering"]) + [InterfaceItem("Tag", items(tags) + [.separator, InterfaceItem("Remove Tag")]), .separator] + items(["Increase Indent", "Decrease Indent"]) + [InterfaceItem("Alignment", items(["Align to Left", "Centre", "Align to Right"])), .separator, InterfaceItem("Restore Image to Original Size"), InterfaceItem("Arrange", items(["Bring Forwards", "Bring to Front", "Send Backwards", "Send to Back"])), InterfaceItem("Table", items(["Insert Rows Above", "Insert Rows Below", "Insert Columns to the Left", "Insert Columns to the Right", "Delete Rows", "Delete Columns", "Delete Table", "Sort A-Z", "Sort Z-A", "Include Header"]))]),
        InterfaceItem("Notebooks", [
            InterfaceItem("Pages", items(["New Page", "Rename Page", "Copy Link to Page", "Make Subpage", "Promote Subpage", "Move Page to…", "Copy Page to…", "Delete Page", "Set as Default Template"])),
            InterfaceItem("Sections", items(["New Section", "New Section Group", "Rename Section", "Copy Link to Section", "Move Section to…", "Copy Section to…", "Delete Section"]) + [InterfaceItem("Password Protection", items(["Protect Current Section", "Lock All Protected Sections"]))]),
            InterfaceItem("Section Groups", items(["Rename", "Delete", "Copy Link to Section Group", "Move Section Group to…"])),
            InterfaceItem("Notebooks", items(["New Notebook…", "Open Notebook…", "Copy Link to Notebook", "Close This Notebook"])),
            InterfaceItem("Deleted Notes", items(["View Deleted Notes", "Empty Deleted Notes", "Disable History for This Notebook"])),
            InterfaceItem("History", items(["Back", "Forwards"]))]),
        InterfaceItem("Tools", items(["Look Up", "Spelling", "Set Proofing Language…"]) + [InterfaceItem("Audio", items(["Record", "Stop", "Play", "Pause", "Back 15 Seconds", "Forwards by 15 Seconds", "Add Bookmark", "Scroll Notes with Audio"])), InterfaceItem("Draw", items(["Text Mode", "Lasso Select", "Insert Space"]) + [InterfaceItem("Eraser", items(["Small Eraser", "Medium Eraser", "Large Eraser", "Stroke Eraser"]))] + items(["Pen", "Marker", "Highlighter"]))]),
        InterfaceItem("Window", items(["Minimise", "Zoom", "New Window", "Bring All to Front", "Minimise All", "Zoom All", "Fill", "Centre"]) + [InterfaceItem("Move & Resize", items(["Left", "Right", "Top", "Bottom", "Top Left", "Top Right", "Bottom Left", "Bottom Right", "Left & Right", "Left & Quarters", "Right & Left", "Right & Quarters", "Top & Bottom", "Top & Quarters", "Bottom & Top", "Bottom & Quarters", "Quarters", "Return to Previous Size"])), InterfaceItem("Full-Screen Tile", items(["Left of Screen", "Right of Screen"])), InterfaceItem("Arrange in Front"), InterfaceItem("Remove Window from Set")]),
        InterfaceItem("Help", items(["OpenOneNote Help", "What’s New", "Feedback", "OneNote Featured Devices", "Clear Application Data", "Check for Updates"]))
    ]
    public static let ribbon: [String: [String]] = [
        "Home": ["Paste", "Cut", "Copy", "Format", "Font:", "Font Size:", "Bulletpoints", "Numbering", "Decrease Indent", "Increase Indent", "Clear Formatting", "Bold", "Italic", "Underline", "Strikethrough", "Subscript and Superscript", "Text Highlight Colour", "Font Colour", "Paragraph Alignment", "Delete", "Styles", "Tags", "Dictate"],
        "Insert": ["Table", "File", "Printout", "Picture", "Screenshot", "Link", "Equation", "Date", "Date & Time", "Shapes", "Audio Recording", "Meeting Details", "Stickers"],
        "Draw": ["Text Mode", "Lasso Select", "Insert Space", "Eraser", "Pen", "Marker", "Highlighter", "Suggested colours", "Ink Colour", "Thickness"],
        "View": ["New Window", "Switch Background", "Page Versions", "Deleted Notes", "Zoom Out", "Zoom In", "Zoom", "Reset Zoom", "Page Width", "Password Protection", "Paper Colour", "Paper Style", "Hide Page Title", "Hide Authors"]
    ]
}
