package com.paraxialtech.vapals.vista;

import com.google.common.base.Preconditions;

import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Represent a Field in a Fileman file.
 * <p/>
 * An instance of this class represents the actual field.
 *
 * @author Keith Powers
 */
public final class FilemanField {
    private String filemanName;
    private String webName;
    private String[] classNum;
    private double propNum;
    private DataTypeEnum dataType;
    /**
     * A map of the shortcut to the possible value (eg: "f"->"female")
     */
    private Map<String, FilemanValueEnumeration> possibleValues;

    private FilemanField() {
        //prevent public instantiation
    }

    public String getFilemanName() {
        return filemanName;
    }

    public String getWebName() {
        return webName;
    }

    public String[] getClassNum() {
        return classNum;
    }

    public Double getPropNum() {
        return propNum;
    }

    public DataTypeEnum getDataType() {
        return dataType;
    }

    public Map<String, FilemanValueEnumeration> getPossibleValues() {
        return possibleValues;
    }

    /**
     * Static constructor generated from a definition file.
     *
     * @param items delimited values from a CSV
     * @param fieldTitles the title of the fields
     * @return fileman field definition
     * @see FilemanValueEnumeration#constructValueFromArray(List, List)
     */
    public static FilemanField constructFromArray(final List<String> items,
                                                  final List<String> fieldTitles) {
        final FilemanField field = new FilemanField();

        String item;
        for (int index = 0; index < items.size(); index++) {
            item = items.get(index);
            switch (fieldTitles.get(index)) {
                case "m-prop-name":
                    field.filemanName = item;
                    break;
                case "Field Name":
                    field.webName = item;
                    break;
                case "m-class-#":
                    field.classNum = item.split("\\.");
                    break;
                case "m-prop-#":
                    field.propNum = Double.parseDouble(item);
                    break;
                case "Data Type":
                    field.dataType = DataTypeEnum.valueOf(item);
                    break;
                case "m-prop-det":  // This value comes after "Data Type" so we can assume a non-null dataType value, but we don't
                    Preconditions.checkNotNull(field.dataType);
                    if (Preconditions.checkNotNull(field.dataType).isEnumeration()) {
                        field.possibleValues = FilemanValueEnumeration.constructMapFromValueList(item);
                        field.mergeWithWebFieldValue(FilemanValueEnumeration.constructValueFromArray(items, fieldTitles));
                    }
                    break;
                // TODO more
            }
        }

        return field;
    }

    /**
     * Take a web field value that was constructed from a definition file (on a
     * different line than the Fileman field values) and merge its value into the
     * list of possible values.
     *
     * @param webFieldValue
     *            A possibly-<code>null</code> web field value constructed from a
     *            line in the definition file.
     */
    void mergeWithWebFieldValue(final FilemanValueEnumeration webFieldValue) {
        if (webFieldValue == null) {
            return;
        }

        final FilemanValueEnumeration filemanFieldValue = this.possibleValues.get(webFieldValue.getShortcut());
        if (filemanFieldValue == null) {
            // TODO: We now have a possible web field value without a corresponding fileman field value. What do we do about this?
            this.possibleValues.put(webFieldValue.getShortcut(), webFieldValue);
        } else {
            filemanFieldValue.setWebValue(webFieldValue.getWebValue());
        }
    }

    /**
     * Get a {@linkplain FilemanValue} object representing the given string.
     *
     * TODO: pass along the expect object for multiSelect types.
     *
     * @param value
     *            The value as seen in Fileman.
     * @return A concrete object
     */
    public final FilemanValue getValueFromFileman(@Nullable final String value) {
        if (value == null || value.trim().length() == 0) {
            return FilemanValue.NO_VALUE;
        }

        if (dataType.isEnumeration()) {
            if (dataType.isMultiSelect()) {
                // TODO
                // if multiple are selected, add each to a FilemanValueMulti
                // else, fall through
            }

            return possibleValues.values().stream()
                .filter(enumeratedValue -> value.equals(enumeratedValue.getFilemanValue()))
                .map(enumeratedValue -> (FilemanValue)enumeratedValue)
                .findFirst()
                .orElse(FilemanValue.NO_VALUE); // TODO: what SHOULD we do here?
//                .get();
        }

        switch (dataType) {
//            case CHECKBOX:
//                break;
            case DATE:
                return FilemanValueDate.fromFileman(value);
            case INTEGER:
                return new FilemanValueNumber(value);
            case PNUM:
                return new FilemanValueNumber(value);
//            case PULLDOWN:
//                break;
//            case RADIO:
//                break;
            case RDATE:
                return FilemanValueDate.fromFileman(value);
            case REAL:
                return new FilemanValueNumber(value);
            case TEXT:
                return new FilemanValueString(value);
            case YEAR:
                try {
                    return new FilemanValueNumber(value);
                } catch (final NumberFormatException e) {
                    break;
                }
            default:
                // Fall-through
        }

        // This should never happen
        return new FilemanValueString(value);
    }

    /**
     *
     *
     * @param elements
     * @return
     */
    public final FilemanValue getValueFromWeb(@Nonnull final Elements elements) {
        if (elements.size() == 0) {
            return FilemanValue.NO_VALUE;
        }

        if (dataType.isEnumeration()) {
            final List<Element> selectedElements = getSelectedElements(elements);

            if (selectedElements.isEmpty()) {
                return FilemanValue.NO_VALUE;
            }

            if (dataType.isMultiSelect()) {
                if (selectedElements.size() > 1) {
                    final List<FilemanValue> selectedValues = selectedElements.stream()
                        .map(element -> possibleValues.values().stream()
                                            .filter(enumeratedValue -> enumeratedValue.getWebValue().equals(element.val()))
                                            .map(enumeratedValue -> (FilemanValue)enumeratedValue)
                                            .findFirst()
                                            .orElse(FilemanValue.NO_VALUE)) // TODO: what SHOULD we do here?
                        .collect(Collectors.toList());

                    return new FilemanValueMulti(selectedValues);
                }
            }

            final Element selectedElement = selectedElements.get(0);

            if (possibleValues.containsKey(selectedElement.val())) {
                return possibleValues.get(selectedElement.val());
            }

            return possibleValues.values().stream()
                .filter(enumeratedValue -> enumeratedValue.getWebValue().equals(selectedElement.val()))
                .map(enumeratedValue -> (FilemanValue)enumeratedValue)
                .findFirst()
                .orElse(FilemanValue.NO_VALUE);    // TODO: what SHOULD we do here?

        }

        final String value = elements.get(0).val();

        if (value == null || value.trim().length() == 0) {
            return FilemanValue.NO_VALUE;
        }

        switch (dataType) {
//            case CHECKBOX:
//                break;
            case DATE:
                return FilemanValueDate.fromWeb(value);
            case INTEGER:
                return new FilemanValueNumber(value);
            case PNUM:
                return new FilemanValueNumber(value);
//            case PULLDOWN:
//                break;
//            case RADIO:
//                break;
            case RDATE:
                FilemanValueDate.fromWeb(value);
            case REAL:
                return new FilemanValueNumber(value);
            case TEXT:
                return new FilemanValueString(value);
            case YEAR:
                return new FilemanValueNumber(value);
            default:
                // Fall-through
        }

        // This should never happen
        return new FilemanValueString(value);
    }

    private List<Element> getSelectedElements(Elements elements) {
        if (dataType == DataTypeEnum.PULLDOWN) {
            return elements.stream()
                .filter(element -> element.hasAttr("selected"))
                .collect(Collectors.toList());
        }
        return elements.stream()
            .filter(element -> element.hasAttr("checked"))
            .collect(Collectors.toList());
    }

    @Override
    public boolean equals(final Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof FilemanField)) {
            return false;
        }

        final FilemanField that = (FilemanField) o;

        if (Double.compare(that.propNum, propNum) != 0) {
            return false;
        }
        if (filemanName != null ? !filemanName.equals(that.filemanName) : that.filemanName != null) {
            return false;
        }
        if (webName != null ? !webName.equals(that.webName) : that.webName != null) {
            return false;
        }
        // Probably incorrect - comparing Object[] arrays with Arrays.equals
        return Arrays.equals(classNum, that.classNum);
    }

    @Override
    public int hashCode() {
        int result;
        long temp;
        result = filemanName != null ? filemanName.hashCode() : 0;
        result = 31 * result + (webName != null ? webName.hashCode() : 0);
        result = 31 * result + Arrays.hashCode(classNum);
        temp = Double.doubleToLongBits(propNum);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("FilemanField{");
        sb.append("filemanName='").append(filemanName).append('\'');
        sb.append(", webName='").append(webName).append('\'');
        sb.append(", classNum=").append(Arrays.toString(classNum));
        sb.append(", propNum=").append(propNum);
        sb.append(", dataType=").append(dataType);
        sb.append(", possibleValues=").append(possibleValues);
        sb.append('}');
        return sb.toString();
    }

    public enum DataTypeEnum {
        CHECKBOX (true,  true),
        DATE     (false),
        INTEGER  (false),
        PNUM     (false),           // What is this? a calculated number?
        PULLDOWN (true,  false),
        RADIO    (true,  false),
        RDATE    (false),
        REAL     (false),
        TEXT     (false),
        YEAR     (false);

        private boolean enumeratedValues;
        private boolean multiSelect;
        private DataTypeEnum(final boolean enumeratedValues) {
            this(enumeratedValues, false);
        }
        private DataTypeEnum(final boolean enumeratedValues, final boolean multiSelect) {
            this.enumeratedValues = enumeratedValues;
            this.multiSelect = multiSelect;
            if (this.multiSelect && !enumeratedValues) {
                throw new IllegalArgumentException("multiSelect is only possible when enumeratedValues=true");
            }
        }

        /**
         * Whether the value for this data type must conform to one of the enumerated
         * values, or whether it may be freely-entered.
         *
         * @return <code>true</code> if this data type is an enumeration,
         *         <code>false</code> otherwise.
         */
        public boolean isEnumeration() {
            return enumeratedValues;
        }

        /**
         * Whether there may be multiple selected values for this data enumerated type,
         * or whether there may be only one.
         * <p/>
         * This value is always <code>false</code> when [{@linkplain #isEnumeration()} is false.
         *
         * @return <code>true</code> if there may be multiple selected value,
         *         <code>false</code> if there may be only one selected value.
         */
        public boolean isMultiSelect() {
            return multiSelect;
        }
    }
}