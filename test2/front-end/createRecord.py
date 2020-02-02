from tkinter import *
import os


window = Tk()
window.title('BlackChain Form')
mainframe = Frame(window)

label = dict()
entry = dict()
values = dict()
optionChoice = StringVar(window)

def submitFunc():
    emptyCheck = False
    for i in range(0,8):
        if(entry[i].index('end') == 0):
            emptyCheck = True
            print("\n Entry field "+str(i)+" is empty.")
            break


    if(emptyCheck == False):
        file = open("./scripts/result.txt","w")
        for i in range(0,8):
            val = entry[i].get()
            values[i] = str(val)
            # print(values[i])
            file.write(values[i]+"\n")
            entry[i].delete(0,END)
        # print(optionChoice.get())
        file.write(optionChoice.get()+"\n")
        file.write(" ")
        optionChoice.set('LOW')
        file.close()
        r = os.popen('./scripts/initLedger.sh').read()
        print(r)
        exit(0)



label[0] = Label(mainframe, text = "User ID ")
label[0].grid(row = 0, column = 0)
entry[0] = Entry(mainframe)
entry[0].grid(row = 0, column = 1)
entry[0]['state'] = 'normal'

label[1] = Label(mainframe, text = "Source Station ")
label[1].grid(row = 1, column = 0)
entry[1] = Entry(mainframe)
entry[1].grid(row = 1, column = 1)
entry[1]['state'] = 'normal'

label[2] = Label(mainframe, text = "Name ")
label[2].grid(row = 2, column = 0)
entry[2] = Entry(mainframe)
entry[2].grid(row = 2, column = 1)
entry[2]['state'] = 'normal'

label[3] = Label(mainframe, text = "Deaprture Date ")
label[3].grid(row = 3, column = 0)
entry[3] = Entry(mainframe)
entry[3].grid(row = 3, column = 1)
entry[3]['state'] = 'normal'

label[4] = Label(mainframe, text = "Phone Number ")
label[4].grid(row = 4, column = 0)
entry[4] = Entry(mainframe)
entry[4].grid(row = 4, column = 1)
entry[4]['state'] = 'normal'

label[5] = Label(mainframe, text = "Credit Card ")
label[5].grid(row = 5, column = 0)
entry[5] = Entry(mainframe)
entry[5].grid(row = 5, column = 1)
entry[5]['state'] = 'normal'

label[6] = Label(mainframe, text = "Aadhar ID ")
label[6].grid(row = 6, column = 0)
entry[6] = Entry(mainframe)
entry[6].grid(row = 6, column = 1)
entry[6]['state'] = 'normal'

label[7] = Label(mainframe, text = "Email ")
label[7].grid(row = 7, column = 0)
entry[7] = Entry(mainframe)
entry[7].grid(row = 7, column = 1)
entry[7]['state'] = 'normal'

accessOptions = {'LOW','MEDIUM','HIGH'}
optionChoice.set('LOW')

menu = OptionMenu(mainframe,optionChoice,*accessOptions)
Label(mainframe,text='Choose access level: ').grid(row = 8,column = 0)
menu.grid(row=8,column = 1)

button = Button(mainframe,text='Submit', command=submitFunc)
button.grid(row = 9 , column = 0)


mainframe.pack()
window.mainloop()
