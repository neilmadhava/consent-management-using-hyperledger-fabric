from tkinter import *
import os

window = Tk()
window.title('BlackChain Querying')
mainframe = Frame(window)

def QueryPublicStuff():
    print('Querying now ... please be patient')
    user = StringVar()
    userId = StringVar()
    user = userType.get()
    userId = entry.get()
    r = os.popen('').read()
    print(r)

def QueryPrivateStuff():
    print('Querying now ... please be patient')
    user = StringVar()
    userId = StringVar()
    user = userType.get()
    userId = entry.get()
    r = os.popen('').read()
    print(r)



userType = StringVar()
userOptions = {'Airport','CCD','User'}
userType.set('User')
menu = OptionMenu(mainframe,userType,*userOptions)
Label(mainframe,text='Select User Type : ').grid(row=0,column=0)
menu.grid(row = 0,column = 1)

Label(mainframe,text='User ID : ').grid(row=1,column=0)
entry = Entry(mainframe)
entry.grid(row = 1,column=1)

button1 = Button(mainframe,text='Query Public Data',command=QueryPublicStuff)
button2 = Button(mainframe,text='Queery Private Data',command=QueryPrivateStuff)
button1.grid(row=2,column=0)
button2.grid(row=2,column=1)
mainframe.pack()
window.mainloop()
