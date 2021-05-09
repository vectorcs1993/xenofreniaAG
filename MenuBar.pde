import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JMenuItem;
import java.awt.Color;

public class MenuBar {
  JFrame frame;
  JMenuBar menu_bar;
  JMenuItem renameBlock, renameParameter, setType, clearGraph, menuNewGame, changeColorGraphBackground, createReport;


  public MenuBar(PApplet app) {

    frame = (JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas)app.getSurface().getNative()).getFrame();


    menu_bar = new JMenuBar();
    frame.setJMenuBar(menu_bar);

    JMenu menuGame = new JMenu("Игра");
    JMenu menuPerson = new JMenu("Персонаж");
    JMenu menu_settings = new JMenu("Настойки");
    JMenu menu_editor = new JMenu("Редактор");


    menu_bar.add(menuGame);
    menu_bar.add(menuPerson);
    menu_bar.add(menu_settings);
    menu_bar.add(menu_editor);

    JMenuItem menuLoadGame = new JMenuItem("Загрузить игру");
    menuNewGame = new JMenuItem("Новая игра");
    JMenuItem menuExit = new JMenuItem("Выход");

    renameBlock = new JMenuItem("Переименовать");

    renameParameter = new JMenuItem("Переименовать");
    setType= new JMenuItem("Изменить");

    clearGraph = new JMenuItem("Очистить");
    changeColorGraphBackground = new JMenuItem("Изменить цвет фона");
    createReport = new JMenuItem("Сформировать отчет");

    menuGame.add(menuLoadGame);
    menuGame.add(menuNewGame);
    menuGame.addSeparator();
    menuGame.add(menuExit);

    menuPerson.add(renameBlock);
    menu_settings.add(renameParameter);
    menu_settings.add(setType);

    menu_editor.add(clearGraph);
    menu_editor.add(changeColorGraphBackground);
    menu_editor.add(createReport);

 
   
    menuExit.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) {
        exit();
      }
    }
    );


    frame.setVisible(true);
  }
  public void update() {
    /*
    if (data.log==null) 
      clear_log.setEnabled(false);
    else 
    clear_log.setEnabled(true);

    if (data.currentGraph.chartsList.isEmpty()) {
      clearGraph.setEnabled(false);
      changeColorGraphBackground.setEnabled(false);
      createReport.setEnabled(false);
    } else {
      clearGraph.setEnabled(true);
      changeColorGraphBackground.setEnabled(true);
      createReport.setEnabled(true);
    }
    if (blocksList.select==null) 
      renameBlock.setEnabled(false);
    else
      renameBlock.setEnabled(true);

    if (parametersList.select==null) {
      renameParameter.setEnabled(false);
      setType.setEnabled(false);
    } else {
      renameParameter.setEnabled(true);
      setType.setEnabled(true);
    }
    
    */
  }
  public void close() {
    menu_bar.revalidate();
  }
}
