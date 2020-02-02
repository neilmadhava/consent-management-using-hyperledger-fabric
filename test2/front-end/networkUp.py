
from tkinter import *
import os


window = Tk()
window.title("BlackChain")
# window.resizable(False,False)
height = 350
width = 400
screenHeight = window.winfo_screenheight()
screenWidth = window.winfo_screenwidth()
x = int((screenWidth/2) - (width/2))
y = int((screenHeight/2) - (height/2))
window.geometry("{}x{}+{}+{}".format(width,height,x,y))
mainframe = Frame(window,background='black',padx=(25),pady=(25))



def generateArtifacts():
    print("\nArtifacts are being generated ... meditate")
    result = int(os.popen('echo $?').read())
    os.popen('./scripts/start.sh').read()
    if(result == 0):
        button1['state'] = 'disabled'
        button2['state'] = 'normal'
        button4['state'] = 'normal'


def createChannel():
    print("\nChannel are being created to enhance Chi flow ... breathe")
    result = int(os.popen('echo $?').read())
    os.popen('./scripts/channel.sh').read()

    if(result == 0):
        button2['state'] = 'disabled'
        print("\nChannel Created Successfully")
        if button3['state'] == 'disabled':
            button3['state'] = 'normal'


def installInstantiate():
    print("\nInstalling and Instantiating Chaicode ... breathe harder")
    result = int(os.popen('echo $?').read())
    os.popen('./scripts/chaincode_start.sh').read()
    if(result == 0):
        button3['state'] = 'disabled'
        print("\nYou have successfully setup the basics ... breathe out")

def refresh():
    print("\nRefreshing the system ... make this smell better")
    result = int(os.popen('echo $?').read())
    os.popen('./scripts/refresh.sh').read()
    if(result == 0):
        button3['state'] = 'disabled'
        button4['state'] = 'disabled'
        button2['state'] = 'disabled'
        button1['state'] = 'normal'
        print("\nEverything has been refreshed ...  smile")

button1 = Button(mainframe,text = "Generate Artifacts",command = generateArtifacts)
button1.grid(row=1,column=0,padx=(10,10),pady=(10,10))
button1.config(height=3,width=40)
button2 = Button(mainframe,text = "Create Channel - Join Peers to Channel", command = createChannel)
button2.grid(row=2,column=0,padx=(10,10),pady=(10,10))
button2.config(height=3,width=40)
button2['state'] = 'disabled'
button3 = Button(mainframe,text = "Install and Instantiate Chaincode on Channel", command = installInstantiate)
button3.grid(row=3,column=0,padx=(10,10),pady=(10,10))
button3.config(height=3,width=40)
button3['state'] = 'disabled'
button4 = Button(mainframe,text = "Teardown Network", command = refresh)
button4.grid(row=4,column=0,padx=(10,10),pady=(10,10))
button4.config(height=3,width=40)
button4['state'] = 'disabled'

mainframe.pack()
window.mainloop()
