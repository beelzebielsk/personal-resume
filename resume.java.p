import javafx.util.Pair;
import java.util.Map;

import org.odftoolkit.simple.TextDocument;

import org.odftoolkit.simple.table.Table;
import org.odftoolkit.simple.table.Cell;
import org.odftoolkit.simple.style.TableCellProperties;
import org.odftoolkit.simple.style.Border;
import org.odftoolkit.simple.style.StyleTypeDefinitions.CellBordersType;

import org.odftoolkit.simple.style.Font;
import org.odftoolkit.simple.style.StyleTypeDefinitions.FontStyle;

class resume {
    public static Table makeTable(TextDocument doc, String[][] data) {
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
    public static void main(String[] args) {
    }
}


class FormatString extends List<Pair<String, Font>> {
    public static defaultFont = new Font("Heuristica", FontStyle.REGULAR, 11);
    //public Map<String, Font> fonts = new ;
    public FormatString(String str) {
        super();
        this.add(new Pair<String, Font>(String, defaultFont));
    }
    public FormatString(List<Pair<String, Font> lst) {
        super();
        for (Pair<String, Font> p : lst) {
            this.appendtext(p.getKey(), p.getValue());
        }
    }
    public void appendText(String str) {
        this.appendText(str, defaultFont);
        return;
    }
    public void appendText(String str, Font f) {
        this.add(new Pair<String, Font>(String, f));
        return;
    }
    public void appendFormatString(FormatString fs) {
        for(Pair<String, Font> p : fs) {
            this.appendText(fs.getKey(), fs.getValue());
        }
        return;
    }
}
