import java.net.URI;
import java.util.Map;

// For the base text document class.
import org.odftoolkit.simple.TextDocument;
import org.odftoolkit.simple.style.MasterPage;

// To manipulate tables (Table) and their cells (Cell)
import org.odftoolkit.simple.table.Table;
import org.odftoolkit.simple.table.Cell;
import org.odftoolkit.simple.table.Column;
import org.odftoolkit.simple.table.Row;
import org.odftoolkit.simple.table.CellStyleHandler;
import org.odftoolkit.simple.style.Border;
import org.odftoolkit.simple.style.TableCellProperties;
import org.odftoolkit.simple.style.DefaultStyleHandler;

// To create and manipulate lists.
import org.odftoolkit.simple.text.list.List;
import org.odftoolkit.simple.text.list.ListItem;
import org.odftoolkit.simple.text.list.BulletDecorator;
import org.odftoolkit.odfdom.dom.attribute.fo.FoMarginLeftAttribute;

// To create and manipulate paragraphs.
import org.odftoolkit.simple.text.Paragraph;
import org.odftoolkit.simple.text.Span;
import org.odftoolkit.simple.text.ParagraphStyleHandler;

import org.odftoolkit.simple.style.StyleTypeDefinitions.HorizontalAlignmentType;
import org.odftoolkit.simple.style.StyleTypeDefinitions.CellBordersType;
import org.odftoolkit.simple.style.StyleTypeDefinitions.LineType;
import org.odftoolkit.simple.style.StyleTypeDefinitions.SupportedLinearMeasure;
import org.odftoolkit.simple.style.Font;
import org.odftoolkit.simple.style.StyleTypeDefinitions.FontStyle;

import org.odftoolkit.odfdom.dom.element.style.StyleMasterPageElement;

// For manipulating styles
import org.odftoolkit.odfdom.incubator.doc.office.OdfOfficeStyles;
import org.odftoolkit.odfdom.dom.style.OdfStyleFamily;
import org.odftoolkit.odfdom.incubator.doc.style.OdfStyle;

// For searching for text.
import org.odftoolkit.simple.common.navigation.TextNavigation;
import org.odftoolkit.simple.common.navigation.TextSelection;


class ResumeExample {
    public static Table newTable(TextDocument doc, String[] rowlabels,
                                 String[] columnlabels, 
                                 String[][] data) 
    {
        Table t = Table.newTable(doc, rowlabels, columnlabels, data);
        t.getCellByPosition(0, 0).setStringValue(data[0][0]);
        return t;
    }
    public static Table newTable(TextDocument doc, String[][] data) {
        Table t = Table.newTable(doc, null, null, data);
        t.getCellByPosition(0, 0).setStringValue(data[0][0]);
        return t;
    }
    public static Table borderlessTable(TextDocument doc, String[][] data) {
        Table t = Table.newTable(doc, null, null, data);
        t.getCellByPosition(0, 0).setStringValue(data[0][0]);

        //DefaultStyleHandler handler = t.getStyleHandler();
        // It looks like you can't get any and all properties from any
        // element. I'm getting back null likely because the table
        // doesn't support tablecellproperties.
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
    public static Table entry(TextDocument doc, String[][] data, Font[][] fonts) 
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

    /** Adds space before the paragraph, p. 
     * The top margin of a paragraph is the same thing as "add space
     * before" in LibreOffice.
     *
     * space is in inches.
     */
    public static void addSpaceBefore(Paragraph p, double space) {
        double inchToMm = 25.4;
        p.getStyleHandler()
            .getParagraphPropertiesForWrite()
            .setMarginTop(space * inchToMm);
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

    /* doc is the document to prepare.
     * marginSize is the size of the margins of all the pages, in
     * inches.
     */
    public static void PrepareDocument(TextDocument doc, double marginSize) throws Exception
    {
        double inchToMm = 25.4;
        double inInches = marginSize * inchToMm;
        // Set the margins of the document.
        /* - Master Pages are a page style that can be applied to
         * other pages, it seems.
         * - To apply the master page style to a page, the only
         *   current way is to use the addPageBreak method. This
         *   applies the master page style to the page after the break
         *   occurs.
         * - To force the new page to become the 1st page, remove the
         *   content of the 1st page, which is the 1st blank paragraph
         *   of the file.
         * - Finally, the new page also has a blank paragraph. Remove
         *   that as well.
         */
        MasterPage master = MasterPage.getOrCreateMasterPage(doc, "Standard");
        master.setMargins(inInches, inInches, inInches, inInches);
        doc.addPageBreak(doc.getParagraphByIndex(0, false), master);
        doc.removeParagraph(doc.getParagraphByIndex(0, false));

        // Remove the 1st blank paragraph of the document.
        doc.removeParagraph(doc.getParagraphByIndex(0, false));
    }
    public static void PrepareDocument(TextDocument doc) throws Exception {
        PrepareDocument(doc, .7);
    }

    public static void main(String[] args) {
        TextDocument doc;
        Paragraph p;
        Table t;
        List l;
        ListItem li;
        String[][] personalInfo = {
            {"ibrahimadam193@gmail.com", "github.com/beelzebielsk"},
            {"(347)-458-8082", "www.linkedin.com/in/adam-ibrahim"}
        };
        String[][] educationalInfo = {
            {"The City University of New York, City College", "Expected: September 2018"},
            {"Bachelor's Of Science, Computer Science", ""},

        };
        Font baseFont = new Font("Heuristica", FontStyle.REGULAR, 11);
        Font baseBold = new Font("Heuristica", FontStyle.BOLD, 11);
        Font heading = new Font("Heuristica", FontStyle.BOLD, 13);
        Font bigHeading = new Font("Heuristica", FontStyle.BOLD, 20);
        Font veryDifferent = new Font("DejaVu Serif", FontStyle.BOLD, 30);
        Font location = new Font("Heuristica", FontStyle.ITALIC, 11);

        //OdfOfficeStyles ofCurrentDoc = new OdfOfficeStyles(doc.getFileDom());
        //OdfStyle style = OdfOfficeStyles.newStyle("resume cell", OdfStyleFamily.TableCell);
        try {
            doc = TextDocument.newTextDocument();
            PrepareDocument(doc);

            p = doc.addParagraph("Adam Ibrahim");
            p.setHorizontalAlignment(HorizontalAlignmentType.CENTER);
            p.setFont(bigHeading);
            t = borderlessTable(doc, personalInfo);
            p = doc.addParagraph("Education");
            p.getStyleHandler().getParagraphPropertiesForWrite().setMarginTop(.50 * 25.4);
            p.setFont(heading);
            //borderlessTable(doc, educationalInfo);
            entry(doc, educationalInfo, new Font[][] 
                    {{baseBold, baseFont}, {location, baseFont}});
            p = doc.addParagraph("Projects");
            p.setFont(heading);
            t = borderlessTable(doc, new String[][] {{"Senior Design Project", "Fall 2017 - Spring 2018"}});
            l = doc.addList();
            l.addItem("Implemented ideas");
            l.addItem("Wrote Project Outline");
            li = l.getItem(1);
            appendTextWithFont(li, doc, " BOLDLY.", veryDifferent);
            l.setDecorator(new BulletDecorator(doc));
            //l.getOdfElement().setOdfAttribute(FoMarginLeftAttribute);
            //l.getOdfElement().setOdfAttributeValue(FoMarginLeftAttribute.ATTRIBUTE_NAME, "5cm");
            //li.getOdfElement().setOdfAttributeValue(FoMarginLeftAttribute.ATTRIBUTE_NAME, "5cm");

            p = doc.addParagraph("This should be (not in bold) ");
            appendTextWithFont(p, "in bold.", veryDifferent);
            System.out.println(veryDifferent.toString());

            //Map<String, StyleMasterPageElement> masterPages = doc.getMasterPages();
            //for (String s : masterPages.keySet()) {
                //System.out.println("Key: " + s);
            //}
            doc.save("resume.odt");

        } catch (Exception e) {
            System.err.println("error occurred.");
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
    }
}

/* DONE:
 * - Add styles to a paragraph of text. Bold, center alignment. (DONE)
 * - Change the spacing before and after a paragraph. Specifically for
 *   section headers. (DONE)
 * - Change the padding of a table. (DONE)
 *      - This is a cell property.
 *      - The TableCellProperties has a field for padding. I may have
 *      to implement the functions that set/get padding values.
 *      - I can look at a file where table cell padding is defined on a
 *      cell and inspect the format of the padding.
 *      - I can look at ParagraphProperties.java for some hints on how
 *      i'm supposed to do this (or other *Properties.java files).
 *      Something that sets a numerical value on a property.
 *      - Defining these means delving a little bit into ODFDOM stuff.
 *      Specifically StyleTableCellPropertiesElement, which has the
 *      method setFoPaddingAttribute. I can use this to set padding
 *      values.
 *      - It worked! For now...
 * - Remove the borders from a table. (DONE)
 * - Change the margins of a page. (DONE)
 * - Create a list. (DONE)
 * - Change font of list text. (DONE)
 * - Change the style of text inside of a paragraph (but not all of
 *   it). (DONE)
/* TODO:
 * - Change left tab stop (left indent) of list.
 *     - Figure out how to select text in a paragraph.
 * - Figure out how to set default font.
 */
