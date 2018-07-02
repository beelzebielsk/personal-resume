import java.net.URI;
import java.util.Map;

// For the base text document class.
import org.odftoolkit.simple.TextDocument;
import org.odftoolkit.simple.style.MasterPage;

// To manipulate tables (Table) and their cells (Cell)
import org.odftoolkit.simple.table.Table;
import org.odftoolkit.simple.table.Cell;
import org.odftoolkit.simple.table.CellStyleHandler;
import org.odftoolkit.simple.style.Border;
import org.odftoolkit.simple.style.TableCellProperties;
import org.odftoolkit.simple.style.DefaultStyleHandler;

// To create and manipulate lists.
import org.odftoolkit.simple.text.list.List;
import org.odftoolkit.simple.text.list.ListItem;

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


class examineListContent {
    public static void main(String[] args) {
        TextDocument doc;
        Paragraph p;
        Table t;
        List l;

        try {
            doc = TextDocument.loadDocument("../output/resume.odt");
            List list = doc.getListIterator().next();
            java.util.List<ListItem> items = list.getItems();
            for (ListItem i : items) {
                System.out.println(i.getTextContent());
            }

        } catch (Exception e) {
            System.err.println("error occurred.");
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
    }
}

/* TODO:
 * - Add styles to a paragraph of text. Bold, center alignment. (DONE)
 * - Change the spacing before and after a paragraph. Specifically for
 *   section headers. (DONE)
 *     - This can be replaced by just putting in a line-break. It's
 *     another option that works for now.
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
 * - Change font of list text.
 * - Change left tab stop (left indent) of list.
 * - Change the style of text inside of a paragraph (but not all of
 *   it).
 *     - Figure out how to select text in a paragraph.
 *     - Figure out how to set default font.
 */
