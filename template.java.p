import java.util.Map;

// Documents and pages
import org.odftoolkit.simple.TextDocument;
import org.odftoolkit.simple.style.MasterPage;

// Paragraphs
import org.odftoolkit.simple.text.Paragraph;
import org.odftoolkit.simple.text.Span;
import org.odftoolkit.simple.text.ParagraphStyleHandler;

// Tables, cells, columns, rows
import org.odftoolkit.simple.table.Table;
import org.odftoolkit.simple.table.Row;
import org.odftoolkit.simple.table.Column;
import org.odftoolkit.simple.table.Cell;
import org.odftoolkit.simple.style.TableCellProperties;
import org.odftoolkit.simple.style.Border;
import org.odftoolkit.simple.style.StyleTypeDefinitions.CellBordersType;
import org.odftoolkit.simple.table.CellStyleHandler;

// Manipulating fonts
import org.odftoolkit.simple.style.Font;
import org.odftoolkit.simple.style.StyleTypeDefinitions.FontStyle;

// Manipulating lists
import org.odftoolkit.simple.text.list.List;
import org.odftoolkit.simple.text.list.ListItem;

// For searching for text.
import org.odftoolkit.simple.common.navigation.TextNavigation;
import org.odftoolkit.simple.common.navigation.TextSelection;

// Other style stuff.
import org.odftoolkit.simple.style.StyleTypeDefinitions.HorizontalAlignmentType;

class ResumeCreator {
    // margin size in millimeters
    public static double inchToMm = 25.4;
    public static double marginSize = .7 * inchToMm;
    public static double spaceBeforeSection = .15 * inchToMm;
    public TextDocument doc;
    /* This is the one masterpage for the whole document. The master
     * page is the page from which all other pages are created.
     */
    public MasterPage masterPage;
    public static Font baseFont = new Font("Heuristica", FontStyle.REGULAR, 11);
    public static Font baseBold = new Font("Heuristica", FontStyle.BOLD, 11);
    public static Font heading  = new Font("Heuristica", FontStyle.BOLD, 13);
    public static Font title    = new Font("Heuristica", FontStyle.BOLD, 20);
    public static Font location = new Font("Heuristica", FontStyle.ITALIC, 11);
    public ResumeCreator() 
    throws Exception {
        doc = TextDocument.newTextDocument();
        masterPage = MasterPage.getOrCreateMasterPage(doc, "Standard");
        masterPage.setMargins(marginSize, marginSize, marginSize, marginSize);
        doc.addPageBreak(doc.getParagraphByIndex(0, false), masterPage);
        doc.removeParagraph(doc.getParagraphByIndex(0, false));
        doc.removeParagraph(doc.getParagraphByIndex(0, false));
    }
    public static Table borderlessTable(TextDocument doc, String[][] data) {
        Table t = Table.newTable(doc, null, null, data);
        t.getCellByPosition(0, 0).setStringValue(data[0][0]);

        for (int row = 0; row < data.length; row++) {
            for (int col = 0; col < data[row].length; col++) {
                Cell c = t.getCellByPosition(col, row);
                CellStyleHandler cHandler = c.getStyleHandler();
                TableCellProperties cProps = cHandler.getTableCellPropertiesForWrite();
                cProps.setPadding(0);
                cHandler.setHorizontalAlignment(
                        col == 0 ?
                        HorizontalAlignmentType.LEFT :
                        HorizontalAlignmentType.RIGHT);
                for(CellBordersType bt : CellBordersType.values()) {
                    c.setBorders(bt, Border.NONE);
                }
            }
        }

        return t;
    }
    public static Table entryTable(TextDocument doc, String[][] data, Font[][] fonts) 
    throws Exception {
        Table t = borderlessTable(doc, data);
        int numColumns = data[0].length - 1;
        Column first = t.getColumnByIndex(0);
        Column last = t.getColumnByIndex(numColumns);
        for (int row = 0; row < data.length; row++) {
            for (int col = 0; col < data[row].length; col++) {
                t.getCellByPosition(col, row).setFont(fonts[row][col]);
            }
        }
        double pageWidth = MasterPage.getOrCreateMasterPage(doc, "Standard").getPageWidth();
        double firstColProportion = .70;
        double lastColProportion = .30;
        first.setWidth(pageWidth * firstColProportion);
        last.setWidth(pageWidth * lastColProportion);
        return t;
    }
    public static void appendTextWithFont(ListItem i, TextDocument doc, String text, Font f) {
        i.setTextContent(i.getTextContent() + text);
        TextNavigation n = new TextNavigation(text, doc);
        TextSelection selection = null;
        // Go to the last selection. This method assumes the given
        // text is at the end of the document.
        // Limiting search scope to just the paragraph does not
        // currently work.
        while(n.hasNext()) {
            selection = (TextSelection) n.nextSelection();
        }
        Span span = Span.newSpan(selection);
        span.getStyleHandler().getTextPropertiesForWrite().setFont(f);
    }
    /**
     * Append the given text to the end of the paragraph, with the
     * given font.
     *
     * Preconditions:
     * - p is the last paragraph in the document.
     *
     * NOTES:
     * - Unfortunately, creating spans is clunky. It requires
     *   searching for text. That, too, is clunky, since limiting my
     *   search to just a single element does not seem to work. 
     *
     * Possible Alternative:
     * - Create and append a span, directly.
     */
    public static void appendTextWithFont(Paragraph p, String text, Font f) {
        p.appendTextContent(text);
        TextDocument doc = (TextDocument) p.getOwnerDocument();
        TextNavigation n = new TextNavigation(text, doc);
        TextSelection selection = null;
        // Go to the last selection. This method assumes the given
        // text is at the end of the document.
        // Limiting search scope to just the paragraph does not
        // currently work.
        while(n.hasNext()) {
            selection = (TextSelection) n.nextSelection();
        }
        Span span = Span.newSpan(selection);
        span.getStyleHandler().getTextPropertiesForWrite().setFont(f);
    }
    /** Adds space before the paragraph, p. 
     * The top margin of a paragraph is the same thing as "add space
     * before" in LibreOffice.
     *
     * space is in millimeters
     */
    public static void addSpaceBefore(Paragraph p, double space) {
        p.getStyleHandler()
            .getParagraphPropertiesForWrite()
            .setMarginTop(space);
    }
    public void addTitle(String text) {
        Paragraph p = doc.addParagraph(text);
        p.setHorizontalAlignment(HorizontalAlignmentType.CENTER);
        p.setFont(title);
    }
    public void addSection(String text) {
        Paragraph p = doc.addParagraph(text);
        p.getStyleHandler().getParagraphPropertiesForWrite().setMarginTop(spaceBeforeSection);
        p.setFont(heading);
    }
    public void addPersonalInfo(String email, String github, String number, String linkedin) {
        borderlessTable(doc, new String[][] {{email, github}, {number, linkedin}});
    }
    public void addEntry(
            String name, String date, String role, String location,
            String[] actions)
    throws Exception {
        Table t = entryTable(
                doc, 
                new String[][] {{name, date}, {role, location}},
                new Font[][] {{baseBold, baseFont}, {ResumeCreator.location, baseFont}});
        List l = doc.addList();
        for (String item : actions) {
            l.addItem(item);
        }
    }
    public void addEntry(String name, String date, String[] actions)
    throws Exception {
        Table t = entryTable(
                doc, 
                new String[][] {{name, date}},
                new Font[][] {{baseBold, baseFont}});
        List l = doc.addList();
        for (String item : actions) {
            l.addItem(item);
        }
    }
    public void addSchool(
            String name, String graduationDate, String degree,
            String courseWork) 
    throws Exception
    {
        Table t = entryTable(
                doc,
                new String[][] {{name, graduationDate}},
                new Font[][] {{baseBold, baseFont}});
        Paragraph p;
        p = doc.addParagraph("");
        appendTextWithFont(p, "Coursework", baseBold);
        p = doc.addParagraph(courseWork);
    }
    public void addSkills(String skillType, String skills) {
        Paragraph p;
        p = doc.addParagraph("");
        appendTextWithFont(p, skillType + ": ", baseBold);
        p.appendTextContent(skills);
    }


}

class resume {
    public static void main(String[] args) {
        try {
            ResumeCreator creator = new ResumeCreator();
            creator.addTitle("Adam Ibrahim");
            ◊(select 'personal-information doc)
            ◊(select 'education-information doc)
            creator.addSection("Technical Skills");
            ◊(select* 'skills doc)
            ◊(select 'projects doc)
            ◊(select 'experience doc)


            creator.doc.save("resume.odt");
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }
}
