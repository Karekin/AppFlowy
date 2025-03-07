import React, { CSSProperties, useEffect, useMemo, useState } from 'react';
import { ReactEditor, useSelected, useSlateStatic } from 'slate-react';
import { Editor, Element, Range } from 'slate';
import { EditorNodeType, HeadingNode } from '$app/application/document/document.types';
import { useTranslation } from 'react-i18next';

function PlaceholderContent({ node, ...attributes }: { node: Element; className?: string; style?: CSSProperties }) {
  const { t } = useTranslation();
  const editor = useSlateStatic();
  const selected = useSelected() && !!editor.selection && Range.isCollapsed(editor.selection);
  const [isComposing, setIsComposing] = useState(false);
  const block = useMemo(() => {
    const path = ReactEditor.findPath(editor, node);
    const match = Editor.above(editor, {
      match: (n) => !Editor.isEditor(n) && Element.isElement(n) && n.blockId !== undefined,
      at: path,
    });

    if (!match) return null;

    return match[0] as Element;
  }, [editor, node]);

  const className = useMemo(() => {
    return `pointer-events-none select-none mx-1 absolute left-0.5 min-h-[26px] top-0 whitespace-nowrap text-text-placeholder ${
      attributes.className ?? ''
    }`;
  }, [attributes.className]);

  const unSelectedPlaceholder = useMemo(() => {
    switch (block?.type) {
      case EditorNodeType.Paragraph: {
        if (editor.children.length === 1) {
          return t('editor.slashPlaceHolder');
        }

        return '';
      }

      case EditorNodeType.ToggleListBlock:
        return t('document.plugins.toggleList');
      case EditorNodeType.QuoteBlock:
        return t('editor.quote');
      case EditorNodeType.TodoListBlock:
        return t('document.plugins.todoList');
      case EditorNodeType.NumberedListBlock:
        return t('document.plugins.numberedList');
      case EditorNodeType.BulletedListBlock:
        return t('document.plugins.bulletedList');
      case EditorNodeType.HeadingBlock: {
        const level = (block as HeadingNode).data.level;

        switch (level) {
          case 1:
            return t('editor.mobileHeading1');
          case 2:
            return t('editor.mobileHeading2');
          case 3:
            return t('editor.mobileHeading3');
          default:
            return '';
        }
      }

      case EditorNodeType.Page:
        return t('document.title.placeholder');
      case EditorNodeType.CalloutBlock:
      case EditorNodeType.CodeBlock:
        return t('editor.typeSomething');
      default:
        return '';
    }
  }, [block, t, editor.children.length]);

  const selectedPlaceholder = useMemo(() => {
    switch (block?.type) {
      case EditorNodeType.HeadingBlock:
        return unSelectedPlaceholder;
      case EditorNodeType.Page:
        return t('document.title.placeholder');
      case EditorNodeType.GridBlock:
      case EditorNodeType.EquationBlock:
      case EditorNodeType.CodeBlock:
        return '';

      default:
        return t('editor.slashPlaceHolder');
    }
  }, [block?.type, t, unSelectedPlaceholder]);

  useEffect(() => {
    if (!selected) return;

    const handleCompositionStart = () => {
      setIsComposing(true);
    };

    const handleCompositionEnd = () => {
      setIsComposing(false);
    };

    const editorDom = ReactEditor.toDOMNode(editor, editor);

    editorDom.addEventListener('compositionstart', handleCompositionStart);
    editorDom.addEventListener('compositionend', handleCompositionEnd);
    return () => {
      editorDom.removeEventListener('compositionstart', handleCompositionStart);
      editorDom.removeEventListener('compositionend', handleCompositionEnd);
    };
  }, [editor, selected]);

  if (isComposing) {
    return null;
  }

  return (
    <span contentEditable={false} {...attributes} className={className}>
      {selected ? selectedPlaceholder : unSelectedPlaceholder}
    </span>
  );
}

export default PlaceholderContent;
