# communityShare

Program allows for the creation of a community share item for rent. Rent is paid to the Item contract at 
which time the ownser gets a fraction for rent, the rest is stored in the Item contract and later returned
to the renter when Item is returned to owner. If not returned the value will slowly pay out to owner 
on a daily basis until value of Item is paid out.