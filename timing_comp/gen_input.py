old = "3210327c68bb9409c4aa5806a4c018e26dcd2ca599a5cbccfaf09c886f701b71"

for i in range(40, 49):
    with open("%d.in"%i, "w") as f:
        f.write(old)
        f.write("\n")
        f.write("%d" % 2**i)
