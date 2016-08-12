#!/usr/bin/perl -w
use Digest::SHA qw(sha512_base64);
no warnings;

#===========Global=======
my @DeckOfCards;
my $DeckIndex;
my @BankerHand;
my @PlayerHand;
my $TargetWins    = 27;
my $MaxGame       = 27;
my $RemGame       = $MaxGame; 
my $Wins          = 0;
my $BlackJackWins = 0;
my $History       = ""; 
my $Status        = "";
#========================

sub ShuffleDeck
{
	@DeckOfCards = (0..51,0..51);  # 2 decks
	$DeckIndex = -1;
	my $i = scalar @DeckOfCards;
    while ( --$i )
    {
        my $j = int rand( $i+1 );
		$exchange = @DeckOfCards[$j];
        @DeckOfCards[$j] = @DeckOfCards[$i];
		@DeckOfCards[$i] = $exchange
    }
}

sub GetCard
{
	$DeckIndex = $DeckIndex + 1;
	if($DeckIndex > scalar(@DeckOfCards))
	{ ShuffleDeck(); }
	return @DeckOfCards[$DeckIndex];
}

sub GetHandValue
{
	my @cards = @_;
	my $cardnum = scalar @_;
	
	my $ace = 0;
	my $cnt = 0;
	my $totalval = 0;
	
	while($cnt < $cardnum)
	{
		$value = int($cards[$cnt] / 4) + 1;	
		if($value == 1)
		{ $ace = 1; }
		elsif($value > 10)
		{ $totalval = $totalval + 10; }
		else
		{ $totalval = $totalval + $value; }
		$cnt = $cnt + 1;
	}
	
	if($ace == 1)
	{
		if($totalval + 11 <= 21)
		{ $totalval = $totalval + 11; }
		else
		{ $totalval = $totalval + 1; }
	}
	return $totalval;
}

sub DisplayHand
{
	my @cards = @_;
	my $cardnum = scalar @_;
	
	my $cnt = 0;
	my $totalval = 0;
	my $hand = "";
	
	while($cnt < $cardnum)
	{
		$suit = $cards[$cnt] % 4;
		if   ($suit == 0) { $suit = "-CLU "; }
		elsif($suit == 1) { $suit = "-SPD "; }
		elsif($suit == 2) { $suit = "-HRT "; }
		else              { $suit = "-DIA "; }
		
		$value = int($cards[$cnt] / 4) + 1;
		if($value == 1)
		{ $hand = $hand . " A" . $suit; }
		elsif($value == 10)
		{ $hand = $hand . "10" . $suit; }		
		elsif($value == 11)
		{ $hand = $hand . " J" . $suit; }
		elsif($value == 12)
		{ $hand = $hand . " Q" . $suit; }
		elsif($value == 13)
		{ $hand = $hand . " K" . $suit; }
		else
		{ $hand = $hand . " " . $value . $suit; }

		$cnt = $cnt + 1;
	}
	return $hand;
}

sub PlayerMove
{
	my $c;	
	my $PlayerHandValue = GetHandValue(@PlayerHand);
	
	while($PlayerHandValue <= 21)
	{
		DisplayTest(1);
		myprint("> [H]it\n");
		myprint("> [S]tand\n");
		myprint("> E[x]it\n");
		myprint("[:] Player Decision:");
		chomp ($c = <>);
		
		if($c =~ /^h/i)
		{ @PlayerHand[scalar @PlayerHand] = GetCard(); }
		elsif($c =~ /^s/i)
		{ last; }
		elsif($c =~ /^x/i)
		{ exit; }
		else
		{ myprint("I do not understand your command ($c)\n");  sleep(1); }
		
		$PlayerHandValue = GetHandValue(@PlayerHand);
	}
}

sub BankStrategy
{
	my $BankHandValue = GetHandValue(@BankerHand);
	while($BankHandValue < 17) #Soft 17
	{
		DisplayTest(0);
		@BankerHand[scalar @BankerHand] = GetCard();
		$BankHandValue = GetHandValue(@BankerHand);
		sleep(1);
	}
	DisplayTest(0);
}

sub CheckWinner
{
	#returns 
	#  0 = banker winner
	#  1 = player winner
	#  2 = Draw
	$BankHandValue = GetHandValue(@BankerHand);    #GlobalVar
	$PlayerHandValue = GetHandValue(@PlayerHand);  #GlobalVar
	
	if(($BankHandValue > 21) && ($PlayerHandValue <= 21))
	{ 
		$Status = "Player Wins! (Banker Bust)";
		return 1;
	}
	elsif(($BankHandValue <= 21) && ($PlayerHandValue > 21))
	{ 
		$Status = "Banker Wins! (Player Bust)";
		return 0;
	}
	elsif(($BankHandValue > 21) && ($PlayerHandValue > 21))
	{ 
		$Status = "Both Bust..";
		return 2;
	}
	elsif($BankHandValue == $PlayerHandValue)
	{ 
		$Status = "Push..";
		return 2;
	}
	elsif($PlayerHandValue > $BankHandValue)
	{ 
		$Status  = "Player Wins!";
		return 1;
	}
	else
	{
		$Status  = "Banker Wins!";
		return 0;
	}
}

sub GenerateFlag
{
	my $rawFlag = "";
	while($DeckIndex < 104)  # Remaining Cards
	{ 
		$rawFlag = $rawFlag . GetCard(); 
	}
	print("testing key: " . sha512_base64($rawFlag) . "\n");
	my $execme = "unrar.exe e -p" . sha512_base64($rawFlag) . " -y DecryptMe.rar";  # Note: You may use any UnRar
	system($execme);
	system("start Decrypted.txt");
	exit();
}

sub DisplayTest
{
	my $limitbanker = $_[0];
	
	system("cls");
	myprint( "[just another game of]                                   28 Sept 2016 GMT\n");
	myprint( "==============================BLACKJACK(21)==============================\n");
	myprint( " In order to win:                                                        \n");
	myprint( " 1. Reach a final score higher than the dealer without exceeding 21.     \n");
	myprint( " 2. Let the dealer draw additional cards until his or her hand exceeds 21\n"); # -Wikipedia
	myprint( " 3. You have to win <" . $TargetWins . "> consecutive times out of <" . $MaxGame . "> games.\n");
	myprint( " 4. 1 of the wins should be a \"blackjack win\".                         \n"); # 1 ACE + 1 Jack of (Spades or clubs)
	myprint( "-------------------------------------------------------------------------\n"); # rule 5: no changing of game logic
	myprint( " Total Wins: $Wins($BlackJackWins) [$RemGame Game(s) Left]                 "); 
	$line1 = " "; $line2 = " "; $line3 = " ";
	
	if($limitbanker > 0)
	{
		myprint( "       Player's Turn\n" );
		myprint( "=========================================================================\n\n");
		myprint("Dealer's Card: (UNK)\n");
		$line1 = $line1 . "--------- ";
		$line2 = $line2 . "| ????? | ";
		$line3 = $line3 . "--------- ";
	}
	else
	{
		myprint( "       Dealer's Move\n" );
		myprint( "=========================================================================\n\n");
		myprint( "Dealer's Card: (" . GetHandValue(@BankerHand) . ")\n");
	}
	while($limitbanker < scalar @BankerHand)
	{
		$line1 = $line1 . "--------- ";
		$line2 = $line2 . "|" . DisplayHand(@BankerHand[$limitbanker]) . "| ";
		$line3 = $line3 . "--------- ";
		$limitbanker = $limitbanker + 1;
	}
	myprint( $line1 . "\n");
	myprint( $line2 . "\n");
	myprint( $line3 . "\n\n");
	
	myprint( "Player's Card: (" . GetHandValue(@PlayerHand) . ")\n");
	$i = 0; $line1 = " "; $line2 = " "; $line3 = " ";
	while($i < scalar @PlayerHand)
	{
		$line1 = $line1 . "--------- ";
		$line2 = $line2 . "|" . DisplayHand(@PlayerHand[$i]) . "| ";
		$line3 = $line3 . "--------- ";
		$i = $i + 1;
	}
	myprint( $line1 . "\n");
	myprint( $line2 . "\n");
	myprint( $line3 . "\n\n");
}

sub myprint
{
	my $stringtoprint = $_[0];
	print $stringtoprint;
	#todo:
}


#-----------------------------------------------
ShuffleDeck(srand(time()));
while( $RemGame-- )
{	
	if($DeckIndex > (scalar @DeckOfCards - 15))
	{ ShuffleDeck(); }
	
	@BankerHand = ();
	@BankerHand[0] = GetCard();
	@BankerHand[1] = GetCard();
	@PlayerHand = ();
	@PlayerHand[0] = GetCard();
	@PlayerHand[1] = GetCard();
	
	my $BankerBJ = 0;
	my $PlayerBJ = 0;
	if(((@BankerHand[0] == 40) || (@BankerHand[0] == 41)) && (GetHandValue(@BankerHand) == 21))
	{ $BankerBJ = 1; }
	if(((@PlayerHand[0] == 40) || (@PlayerHand[0] == 41)) && (GetHandValue(@PlayerHand) == 21))
	{ $PlayerBJ = 1; }
	
	if($PlayerBJ && $BankerBJ)
	{ 
		DisplayTest(0);
		myprint("[:] Push.. Both Black Jack!?!\n"); 
		myprint("[:] Lost (not enough remaining games to win)\n");
		last;
	}
	elsif($PlayerBJ)
	{
		$Wins = $Wins + 1;
		$BlackJackWins = $BlackJackWins + 1;
		DisplayTest(0);
		myprint("[:] Player Wins! Black Jack!\n");
	}
	elsif($BankerBJ)
	{
		DisplayTest(0);
		myprint("[:] Banker Wins! Black Jack!\n");
		myprint("[:] You lost...\n");
		last;
	}
	else
	{	
		PlayerMove();
		BankStrategy();

		$Winner = CheckWinner();
		if($Winner == 0)
		{
			myprint("[:] $Status\n");
			last;
		}
		elsif($Winner == 1)
		{ 
			$Wins = $Wins + 1;
			DisplayTest(0);
			myprint("[:] $Status\n");
			if(($Wins >= $TargetWins) && $BlackJackWins)
			{ GenerateFlag(); }
		}
		else
		{
			myprint("[:] $Status (not enough remaining games to win)\n");
			last;
		}
	}
	myprint("[x] Press any key to continue..\n");
    my $resp = <STDIN>;
}
#----------------------bSy 17.06.2016----------------------
