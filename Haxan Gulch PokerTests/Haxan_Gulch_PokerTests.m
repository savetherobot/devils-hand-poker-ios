//
//  Haxan_Gulch_PokerTests.m
//  Haxan Gulch PokerTests
//
//  Created by Chris Dahlen on 1/2/17.
//  Copyright © 2017 Team Wetigan. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Constants.h"
#import "HandEvaluator.h"
#import "BetEvaluator.h"
#import "Card.h"

@interface Haxan_Gulch_PokerTests : XCTestCase

@end

@implementation Haxan_Gulch_PokerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

-(void)testHighLowBetsAndLowHands {
    NSArray<Card*>* mediocreLowHand = @[[[Card alloc] initWithRank:5 suit:Clubs],
                                        [[Card alloc] initWithRank:6 suit:Diamonds],
                                        [[Card alloc] initWithRank:3 suit:Diamonds],
                                        [[Card alloc] initWithRank:11 suit:Clubs],
                                        [[Card alloc] initWithRank:8 suit:Clubs],
                                        [[Card alloc] initWithRank:11 suit:Diamonds],
                                        [[Card alloc] initWithRank:2 suit:Clubs]];
    
    int lowHandValue = [HandEvaluator getFinalLowHandValue:mediocreLowHand wildCards:0];
    XCTAssert(lowHandValue == 86532);
    
    NSArray<Card*>* theWheel = @[[[Card alloc] initWithRank:14 suit:Spades],
                                 [[Card alloc] initWithRank:2 suit:Spades],
                                 [[Card alloc] initWithRank:3 suit:Diamonds],
                                 [[Card alloc] initWithRank:4 suit:Diamonds],
                                 [[Card alloc] initWithRank:5 suit:Diamonds],
                                 [[Card alloc] initWithRank:12 suit:Hearts]];
    
    // Check out the probabilities that it assigns to potential low hands, based on how close they are to the wheel
    NSArray<Card*>* possibleWheel1 =  @[[[Card alloc] initWithRank:14 suit:Spades],
                                        [[Card alloc] initWithRank:2 suit:Spades],
                                        [[Card alloc] initWithRank:5 suit:Diamonds]];
    
    HandEvaluation* possibleWheelTest1 = [HandEvaluator evaluateLowPokerHand:possibleWheel1 wildCards:0 unknownCards:[self createDeckOmittingSpecifiedCards:possibleWheel1] handSize:7];
    
    XCTAssert(possibleWheelTest1.probability > 0.05f);
    
    NSArray<Card*>* possibleWheel2 =  @[[[Card alloc] initWithRank:14 suit:Spades],
                                        [[Card alloc] initWithRank:2 suit:Spades],
                                        [[Card alloc] initWithRank:5 suit:Diamonds],
                                        [[Card alloc] initWithRank:3 suit:Diamonds]];
    
    HandEvaluation* possibleWheelTest2 = [HandEvaluator evaluateLowPokerHand:possibleWheel2 wildCards:0 unknownCards:[self createDeckOmittingSpecifiedCards:possibleWheel2] handSize:7];
    
    XCTAssert(possibleWheelTest2.probability > 0.2f);
    
    NSArray<Card*>* possibleWheel3 =  @[[[Card alloc] initWithRank:14 suit:Spades],
                                        [[Card alloc] initWithRank:2 suit:Spades],
                                        [[Card alloc] initWithRank:5 suit:Diamonds],
                                        [[Card alloc] initWithRank:4 suit:Diamonds],
                                        [[Card alloc] initWithRank:3 suit:Diamonds]];
    
    HandEvaluation* possibleWheelTest3 = [HandEvaluator evaluateLowPokerHand:possibleWheel3 wildCards:0 unknownCards:[self createDeckOmittingSpecifiedCards:possibleWheel3] handSize:7];
    
    XCTAssert(possibleWheelTest3.probability == 1.0);
    
    // Test the Bet Evaluator
    Player* player0 = [[Player alloc] init:@"Unit Test 0" holdings:100 playerType:PlayerTypeHuman];
    Player* player1 = [[Player alloc] init:@"Unit Test 1" holdings:100 playerType:PlayerTypeNPC_Simple];
    Player* player2 = [[Player alloc] init:@"Unit Test 2" holdings:100 playerType:PlayerTypeNPC_Simple];
    Player* player3 = [[Player alloc] init:@"Unit Test 3" holdings:100 playerType:PlayerTypeNPC_Simple];
    
    // Hands for testing the NPCs
    
    // A so-so low hand
    player0.hand = mediocreLowHand;
    
    // Should go low and high
    player1.hand = @[ [[Card alloc] initWithRank:2 suit:Diamonds],
                         [[Card alloc] initWithRank:3 suit:Diamonds],
                         [[Card alloc] initWithRank:4 suit:Diamonds],
                         [[Card alloc] initWithRank:5 suit:Diamonds],
                         [[Card alloc] initWithRank:6 suit:Diamonds],
                         [[Card alloc] initWithRank:9 suit:Clubs],
                         [[Card alloc] initWithRank:10 suit:Spades]
                         ];
    
    // Should also go low and high, but lose (since it's a straight but not a flush)
    player2.hand = @[ [[Card alloc] initWithRank:2 suit:Spades],
                         [[Card alloc] initWithRank:3 suit:Hearts],
                         [[Card alloc] initWithRank:4 suit:Spades],
                         [[Card alloc] initWithRank:5 suit:Hearts],
                         [[Card alloc] initWithRank:6 suit:Spades],
                         [[Card alloc] initWithRank:9 suit:Clubs],
                         [[Card alloc] initWithRank:10 suit:Spades]
                         ];
    
    // Has to be a high hand, but it's only a pair
    player3.hand = @[[[Card alloc] initWithRank:7 suit:Hearts],
                     [[Card alloc] initWithRank:12 suit:Clubs],
                     [[Card alloc] initWithRank:14 suit:Hearts],
                     [[Card alloc] initWithRank:12 suit:Diamonds],
                     [[Card alloc] initWithRank:11 suit:Spades],
                     [[Card alloc] initWithRank:9 suit:Diamonds],
                     [[Card alloc] initWithRank:10 suit:Clubs]];
    
    NSDictionary* resultsDict = [BetEvaluator evaluateHighLowAndBothWinners:@[player0, player1, player2, player3] playerBetType:HighLowBetLow wildCardRanks:@[]];
    
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighHand] intValue] == 3);
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighAndLowHand] intValue] == 1);
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningLowHand] intValue] == 0);
    
    // Now put in the wheel and make sure that it wins the low hand, and knocks out the "both" hands
    player0.hand = theWheel;
    
    resultsDict = [BetEvaluator evaluateHighLowAndBothWinners:@[player0, player1, player2, player3] playerBetType:HighLowBetLow wildCardRanks:@[]];
    
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighHand] intValue] == 3);
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningHighAndLowHand] intValue] == -1);
    XCTAssert([[resultsDict valueForKey:kHGPIndexOfPlayerWithWinningLowHand] intValue] == 0);
}

-(void)testHandComparison {
    ///////////////////////////////////////////
    // Royal flushes, use the kicker cards for comparison
    NSArray<Card*>* handFlushFaceValueA = @[ [[Card alloc] initWithRank:14 suit:Diamonds],
                                             [[Card alloc] initWithRank:13 suit:Diamonds],
                                             [[Card alloc] initWithRank:12 suit:Diamonds],
                                             [[Card alloc] initWithRank:11 suit:Diamonds],
                                             [[Card alloc] initWithRank:10 suit:Diamonds],
                                             [[Card alloc] initWithRank:7 suit:Clubs],
                                             [[Card alloc] initWithRank:6 suit:Spades]
                                             ];
    
    NSArray<Card*>* handFlushFaceValueB = @[ [[Card alloc] initWithRank:14 suit:Spades],
                                             [[Card alloc] initWithRank:13 suit:Spades],
                                             [[Card alloc] initWithRank:12 suit:Spades],
                                             [[Card alloc] initWithRank:11 suit:Spades],
                                             [[Card alloc] initWithRank:10 suit:Spades],
                                             [[Card alloc] initWithRank:8 suit:Clubs],
                                             [[Card alloc] initWithRank:4 suit:Diamonds]
                                             ];
    
    HandEvaluation* handFlushFaceValueAEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueA wildCards:0];
    HandEvaluation* handFlushFaceValueBEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueB wildCards:0];
    
    XCTAssert(handFlushFaceValueAEval.type == RoyalFlush);
    XCTAssert(handFlushFaceValueBEval.type == RoyalFlush);
    
    // The 8 of Clubs kicker card beats the 7 of Clubs kicker card
    XCTAssert([HandEvaluator compareHand:handFlushFaceValueAEval toHand:handFlushFaceValueBEval] == NSOrderedAscending);
    
    // Royal flushes with wild cards
    NSArray<Card*>* handFlushFaceValueC = @[ [[Card alloc] initWithRank:14 suit:Diamonds],
                                            // [[Card alloc] initWithRank:13 suit:Diamonds],    // Wild cards
                                            // [[Card alloc] initWithRank:12 suit:Diamonds],
                                             [[Card alloc] initWithRank:11 suit:Diamonds],
                                             [[Card alloc] initWithRank:10 suit:Diamonds],
                                             [[Card alloc] initWithRank:7 suit:Clubs],
                                             [[Card alloc] initWithRank:6 suit:Spades]
                                             ];
    
    NSArray<Card*>* handFlushFaceValueD = @[ [[Card alloc] initWithRank:14 suit:Spades],
                                            // [[Card alloc] initWithRank:13 suit:Spades],  // Wild card
                                             [[Card alloc] initWithRank:12 suit:Spades],
                                             [[Card alloc] initWithRank:11 suit:Spades],
                                             [[Card alloc] initWithRank:10 suit:Spades],
                                             [[Card alloc] initWithRank:8 suit:Clubs],
                                             [[Card alloc] initWithRank:4 suit:Diamonds]
                                             ];
    
    HandEvaluation* handFlushFaceValueCEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueC wildCards:2];
    HandEvaluation* handFlushFaceValueDEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueD wildCards:1];

    XCTAssert(handFlushFaceValueCEval.type == RoyalFlush);
    XCTAssert(handFlushFaceValueDEval.type == RoyalFlush);
    
    // The 8 of Clubs kicker card beats the 7 of Clubs kicker card
    XCTAssert([HandEvaluator compareHand:handFlushFaceValueCEval toHand:handFlushFaceValueDEval] == NSOrderedAscending);
    
    // Royal flushes where a wild card is one of the kicker cards
    NSArray<Card*>* handFlushFaceValueE = @[ [[Card alloc] initWithRank:14 suit:Diamonds],
                                             // [[Card alloc] initWithRank:13 suit:Diamonds],    // Wild cards
                                             // [[Card alloc] initWithRank:12 suit:Diamonds],
                                             [[Card alloc] initWithRank:11 suit:Diamonds],
                                             [[Card alloc] initWithRank:10 suit:Diamonds],
                                          //   [[Card alloc] initWithRank:7 suit:Clubs],    // Kicker is wild
                                             [[Card alloc] initWithRank:6 suit:Spades]
                                             ];
    
    NSArray<Card*>* handFlushFaceValueF = @[ [[Card alloc] initWithRank:14 suit:Spades],
                                             // [[Card alloc] initWithRank:13 suit:Spades],  // Wild card
                                             [[Card alloc] initWithRank:12 suit:Spades],
                                             [[Card alloc] initWithRank:11 suit:Spades],
                                             [[Card alloc] initWithRank:10 suit:Spades],
                                             [[Card alloc] initWithRank:8 suit:Clubs],
                                             [[Card alloc] initWithRank:4 suit:Diamonds]
                                             ];
    
    HandEvaluation* handFlushFaceValueEEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueE wildCards:3];
    HandEvaluation* handFlushFaceValueFEval = [HandEvaluator getFinalRankingOfHand:handFlushFaceValueF wildCards:1];
    
    XCTAssert(handFlushFaceValueEEval.type == RoyalFlush);
    XCTAssert(handFlushFaceValueFEval.type == RoyalFlush);
    
    // The wild card in E should beat the 8 of Clubs in F
    XCTAssert([HandEvaluator compareHand:handFlushFaceValueEEval toHand:handFlushFaceValueFEval] == NSOrderedDescending);
    
    ///////////////////////////////////////////
    // Straight flushes
   
    // Compare two natural straight flushes
    NSArray<Card*>* handStraightFlushA = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Diamonds],
                                       [[Card alloc] initWithRank:6 suit:Diamonds],
                                       [[Card alloc] initWithRank:5 suit:Diamonds],
                                       [[Card alloc] initWithRank:3 suit:Diamonds],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]
                                       ];
    
    // B tops out at 8 and beats hand A
    NSArray<Card*>* handStraightFlushB = @[ [[Card alloc] initWithRank:8 suit:Clubs],
                                       [[Card alloc] initWithRank:7 suit:Clubs],
                                       [[Card alloc] initWithRank:4 suit:Clubs],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Clubs],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]];
    
    HandEvaluation* handStraightFlushAEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushA wildCards:0];
    HandEvaluation* handStraightFlushBEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushB wildCards:0];
    
    XCTAssert(handStraightFlushAEval.type == StraightFlush);
    XCTAssert(handStraightFlushBEval.type == StraightFlush);
    
    XCTAssert([HandEvaluator compareHand:handStraightFlushAEval toHand:handStraightFlushBEval] == NSOrderedAscending);
    
    // C has the same natural cards but will also have a wild card, and should beat D
    NSArray<Card*>* handStraightFlushC = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Diamonds],
                                       [[Card alloc] initWithRank:6 suit:Diamonds],
                                       [[Card alloc] initWithRank:5 suit:Diamonds],
                                       [[Card alloc] initWithRank:3 suit:Diamonds],
                                       [[Card alloc] initWithRank:14 suit:Hearts]
                                       ];
    
    NSArray<Card*>* handStraightFlushD = @[ [[Card alloc] initWithRank:7 suit:Hearts],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Hearts],
                                       [[Card alloc] initWithRank:3 suit:Hearts],
                                       [[Card alloc] initWithRank:14 suit:Hearts]
                                       ];
    
    HandEvaluation* handStraightFlushCEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushC wildCards:1];
    HandEvaluation* handStraightFlushDEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushD wildCards:0];
    
    XCTAssert(handStraightFlushCEval.type == StraightFlush);
    XCTAssert(handStraightFlushDEval.type == StraightFlush);
    
    XCTAssert([HandEvaluator compareHand:handStraightFlushCEval toHand:handStraightFlushDEval] == NSOrderedDescending);
    
    // E should beat F on kicker cards
    NSArray<Card*>* handStraightFlushE = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Diamonds],
                                       [[Card alloc] initWithRank:6 suit:Diamonds],
                                       [[Card alloc] initWithRank:5 suit:Diamonds],
                                       [[Card alloc] initWithRank:3 suit:Diamonds],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Hearts]
                                       ];
    
    NSArray<Card*>* handStraightFlushF = @[ [[Card alloc] initWithRank:7 suit:Hearts],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Hearts],
                                       [[Card alloc] initWithRank:3 suit:Hearts],
                                       [[Card alloc] initWithRank:13 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]
                                       ];
    
    HandEvaluation* handStraightFlushEEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushE wildCards:0];
    HandEvaluation* handStraightFlushFEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushF wildCards:0];
    
    XCTAssert(handStraightFlushEEval.type == StraightFlush);
    XCTAssert(handStraightFlushFEval.type == StraightFlush);
    
    XCTAssert([HandEvaluator compareHand:handStraightFlushEEval toHand:handStraightFlushFEval] == NSOrderedDescending);
    
    // G uses wild cards to beat H by filling in one gap and then reaching up to an 8
    NSArray<Card*>* handStraightFlushG = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       ];
    
    NSArray<Card*>* handStraightFlushH = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       ];
    
    HandEvaluation* handStraightFlushGEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushG wildCards:2];
    HandEvaluation* handStraightFlushHEval = [HandEvaluator getFinalRankingOfHand:handStraightFlushH wildCards:0];
    
    XCTAssert(handStraightFlushGEval.type == Straight);
    XCTAssert(handStraightFlushHEval.type == Straight);
    
    XCTAssert([HandEvaluator compareHand:handStraightFlushGEval toHand:handStraightFlushHEval] == NSOrderedDescending);
    
    // Now we'll just make sure it's registering some straight flushes
    NSArray<Card*>* handPartialStraightFlush = @[ [[Card alloc] initWithRank:5 suit:Diamonds],
                                             [[Card alloc] initWithRank:4 suit:Diamonds],
                                             [[Card alloc] initWithRank:6 suit:Diamonds]];
    HandEvaluation* handPartialStraightFlushEval = [HandEvaluator getFinalRankingOfHand:handPartialStraightFlush wildCards:2];
    XCTAssert(handPartialStraightFlushEval.type == StraightFlush);
    
    NSArray<Card*>* handPartialStraightFlushWithGaps1 = @[ [[Card alloc] initWithRank:5 suit:Diamonds],
                                                      [[Card alloc] initWithRank:4 suit:Diamonds],
                                                      [[Card alloc] initWithRank:8 suit:Diamonds]];
    HandEvaluation* handPartialStraightFlushWithGaps1Eval = [HandEvaluator getFinalRankingOfHand:handPartialStraightFlushWithGaps1 wildCards:2];
    XCTAssert(handPartialStraightFlushWithGaps1Eval.type == StraightFlush);
    
    NSArray<Card*>* handPartialStraightFlushWithGaps2 = @[ [[Card alloc] initWithRank:3 suit:Diamonds],
                                                      [[Card alloc] initWithRank:5 suit:Diamonds],
                                                      [[Card alloc] initWithRank:9 suit:Diamonds],
                                                      [[Card alloc] initWithRank:8 suit:Diamonds]];
    HandEvaluation* handPartialStraightFlushWithGaps2Eval = [HandEvaluator getFinalRankingOfHand:handPartialStraightFlushWithGaps2 wildCards:2];
    XCTAssert(handPartialStraightFlushWithGaps2Eval.type == StraightFlush);
    
    // Just or laughs, check the last two with gaps. The 9 should beat the 8
    XCTAssert([HandEvaluator compareHand:handPartialStraightFlushWithGaps1Eval toHand:handPartialStraightFlushWithGaps2Eval] == NSOrderedAscending);
    
    
    ///////////////////////////////////////////
    // Four of a kind (the David Carlton bug)
    NSArray<Card*>* handFourOfAKindA = @[ [[Card alloc] initWithRank:11 suit:Clubs],
                                         // [[Card alloc] initWithRank:3 suit:Diamonds],    // Wild card
                                          [[Card alloc] initWithRank:7 suit:Clubs],
                                          [[Card alloc] initWithRank:6 suit:Diamonds],
                                          [[Card alloc] initWithRank:6 suit:Clubs],
                                          [[Card alloc] initWithRank:6 suit:Hearts],
                                          [[Card alloc] initWithRank:4 suit:Diamonds]];
    
    NSArray<Card*>* handFourOfAKindB = @[ //[[Card alloc] initWithRank:3 suit:Hearts],  // Wild cards
                                          [[Card alloc] initWithRank:11 suit:Hearts],
                                          //[[Card alloc] initWithRank:9 suit:Clubs],
                                          [[Card alloc] initWithRank:4 suit:Hearts],
                                          [[Card alloc] initWithRank:8 suit:Spades],
                                         // [[Card alloc] initWithRank:9 suit:Spades],
                                          [[Card alloc] initWithRank:14 suit:Clubs],
                                          [[Card alloc] initWithRank:2 suit:Diamonds]];
    
    HandEvaluation* handFourOfAKindAEval = [HandEvaluator getFinalRankingOfHand:handFourOfAKindA wildCards:1];
    HandEvaluation* handFourOfAKindBEval = [HandEvaluator getFinalRankingOfHand:handFourOfAKindB wildCards:3];
    
    XCTAssert([HandEvaluator compareHand:handFourOfAKindAEval toHand:handFourOfAKindBEval] == NSOrderedAscending);
    
    // Four of a kind where the rank is the same, so the comparison depends on the kicker cards
    NSArray<Card*>* handFourOfAKindC = @[[[Card alloc] initWithRank:14 suit:Hearts],
                                         [[Card alloc] initWithRank:8 suit:Spades],
                                         [[Card alloc] initWithRank:7 suit:Hearts],
                                         [[Card alloc] initWithRank:2 suit:Diamonds]];
    
    NSArray<Card*>* handFourOfAKindD = @[[[Card alloc] initWithRank:14 suit:Clubs],
                                         [[Card alloc] initWithRank:9 suit:Spades],
                                         [[Card alloc] initWithRank:4 suit:Hearts],
                                         [[Card alloc] initWithRank:3 suit:Diamonds]];
    
    HandEvaluation* handFourOfAKindCEval = [HandEvaluator getFinalRankingOfHand:handFourOfAKindC wildCards:3];
    HandEvaluation* handFourOfAKindDEval = [HandEvaluator getFinalRankingOfHand:handFourOfAKindD wildCards:3];
    
    XCTAssert([HandEvaluator compareHand:handFourOfAKindCEval toHand:handFourOfAKindDEval] == NSOrderedAscending);
    
    ///////////////////////////////////////////
    // Full house
    NSArray<Card*>* handFullHouseA = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:4 suit:Clubs],
                                       [[Card alloc] initWithRank:7 suit:Spades],
                                       [[Card alloc] initWithRank:7 suit:Hearts],
                                       [[Card alloc] initWithRank:11 suit:Spades],
                                       [[Card alloc] initWithRank:9 suit:Diamonds]];

    NSArray<Card*>* handFullHouseB = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                        [[Card alloc] initWithRank:4 suit:Hearts],
                                        [[Card alloc] initWithRank:4 suit:Clubs],
                                        [[Card alloc] initWithRank:7 suit:Spades],
                                        [[Card alloc] initWithRank:7 suit:Hearts],
                                        [[Card alloc] initWithRank:9 suit:Spades],
                                        [[Card alloc] initWithRank:2 suit:Diamonds]];
    
    HandEvaluation* handFullHouseAEval = [HandEvaluator getFinalRankingOfHand:handFullHouseA wildCards:0];
    HandEvaluation* handFullHouseBEval = [HandEvaluator getFinalRankingOfHand:handFullHouseB wildCards:0];
    
    XCTAssert(handFullHouseAEval.type == FullHouse);
    XCTAssert(handFullHouseBEval.type == FullHouse);
    
    // Hand C should win on kicker cards
    XCTAssert([HandEvaluator compareHand:handFullHouseAEval toHand:handFullHouseBEval] == NSOrderedDescending);
    
    NSArray<Card*>* handFullHouseC = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                        [[Card alloc] initWithRank:4 suit:Hearts],
                                        [[Card alloc] initWithRank:4 suit:Clubs],
                                        [[Card alloc] initWithRank:7 suit:Spades],
                                     //   [[Card alloc] initWithRank:7 suit:Hearts],
                                        [[Card alloc] initWithRank:11 suit:Spades],
                                        [[Card alloc] initWithRank:9 suit:Diamonds]];
    
    NSArray<Card*>* handFullHouseD = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                        [[Card alloc] initWithRank:4 suit:Hearts],
                                        [[Card alloc] initWithRank:4 suit:Clubs],
                                        [[Card alloc] initWithRank:7 suit:Spades],
                                   //     [[Card alloc] initWithRank:7 suit:Hearts],
                                        [[Card alloc] initWithRank:9 suit:Spades],
                                        [[Card alloc] initWithRank:2 suit:Diamonds]];
    
    HandEvaluation* handFullHouseCEval = [HandEvaluator getFinalRankingOfHand:handFullHouseC wildCards:1];
    HandEvaluation* handFullHouseDEval = [HandEvaluator getFinalRankingOfHand:handFullHouseD wildCards:1];
    
    XCTAssert(handFullHouseCEval.type == FullHouse);
    XCTAssert(handFullHouseDEval.type == FullHouse);
    
    // Hand C should win on kicker cards
    XCTAssert([HandEvaluator compareHand:handFullHouseCEval toHand:handFullHouseDEval] == NSOrderedDescending);

    ///////////////////////////////////////////
    // Flushes
    
    // B should beat A so long as the wild cards pay off
    NSArray<Card*>* handFlushA = @[ [[Card alloc] initWithRank:12 suit:Diamonds],
                                    [[Card alloc] initWithRank:2 suit:Diamonds],
                                    [[Card alloc] initWithRank:3 suit:Diamonds],
                                    [[Card alloc] initWithRank:7 suit:Diamonds],
                                    [[Card alloc] initWithRank:9 suit:Diamonds],
                                    [[Card alloc] initWithRank:2 suit:Hearts],
                                    [[Card alloc] initWithRank:14 suit:Hearts]];
    
    NSArray<Card*>* handFlushB = @[ [[Card alloc] initWithRank:10 suit:Diamonds],
                                    [[Card alloc] initWithRank:2 suit:Diamonds],
                                    [[Card alloc] initWithRank:3 suit:Diamonds],
                                    [[Card alloc] initWithRank:7 suit:Hearts],
                                    [[Card alloc] initWithRank:14 suit:Hearts]];
    
    HandEvaluation* handFlushAEval = [HandEvaluator getFinalRankingOfHand:handFlushA wildCards:0];
    HandEvaluation* handFlushBEval = [HandEvaluator getFinalRankingOfHand:handFlushB wildCards:2];
    
    XCTAssert(handFlushAEval.type == Flush);
    XCTAssert(handFlushBEval.type == Flush);
    
    XCTAssert([HandEvaluator compareHand:handFlushAEval toHand:handFlushBEval] == NSOrderedAscending);
    
    ///////////////////////////////////////////
    // Straights
    NSArray<Card*>* handDavidCarltonStraight1WC = @[ //[[Card alloc] initWithRank:3 suit:Hearts], // Wild card
                                                    [[Card alloc] initWithRank:10 suit:Clubs],
                                                    [[Card alloc] initWithRank:12 suit:Spades],
                                                    [[Card alloc] initWithRank:7 suit:Clubs],
                                                    [[Card alloc] initWithRank:13 suit:Hearts],
                                                    [[Card alloc] initWithRank:2 suit:Hearts],
                                                    [[Card alloc] initWithRank:14 suit:Hearts]
                                                    ];
    
    HandEvaluation* handDavidCarltonStraight1WCEval = [HandEvaluator getFinalRankingOfHand:handDavidCarltonStraight1WC wildCards:1];
    
    XCTAssert(handDavidCarltonStraight1WCEval.type == Straight);
    
    NSArray<Card*>* handDavidCarltonStraight2WC = @[ //[[Card alloc] initWithRank:3 suit:Hearts], // Wild card
                                                    //  [[Card alloc] initWithRank:10 suit:Clubs],
                                                    [[Card alloc] initWithRank:12 suit:Spades],
                                                    [[Card alloc] initWithRank:7 suit:Clubs],
                                                    [[Card alloc] initWithRank:13 suit:Hearts],
                                                    [[Card alloc] initWithRank:2 suit:Diamonds],
                                                    [[Card alloc] initWithRank:14 suit:Hearts]
                                                    ];
    
    HandEvaluation* handDavidCarltonStraight2WCEval = [HandEvaluator getFinalRankingOfHand:handDavidCarltonStraight2WC wildCards:2];
    
    XCTAssert(handDavidCarltonStraight2WCEval.type == Straight);
    
    // Compare two natural straights
    NSArray<Card*>* handStraightA = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                      [[Card alloc] initWithRank:4 suit:Hearts],
                                      [[Card alloc] initWithRank:6 suit:Clubs],
                                      [[Card alloc] initWithRank:5 suit:Spades],
                                      [[Card alloc] initWithRank:3 suit:Clubs],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]
                                       ];
    
    // B tops out at 8 and beats hand A
    NSArray<Card*>* handStraightB = @[ [[Card alloc] initWithRank:8 suit:Clubs],
                                       [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]];
    
    HandEvaluation* handStraightAEval = [HandEvaluator getFinalRankingOfHand:handStraightA wildCards:0];
    HandEvaluation* handStraightBEval = [HandEvaluator getFinalRankingOfHand:handStraightB wildCards:0];
    
    XCTAssert(handStraightAEval.type == Straight);
    XCTAssert(handStraightBEval.type == Straight);
    
    XCTAssert([HandEvaluator compareHand:handStraightAEval toHand:handStraightBEval] == NSOrderedAscending);
    
    // C has the same natural cards but will also have a wild card, and should beat D
    NSArray<Card*>* handStraightC = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       [[Card alloc] initWithRank:14 suit:Hearts]
                                       ];
    
    NSArray<Card*>* handStraightD = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       [[Card alloc] initWithRank:14 suit:Hearts]
                                       ];
    
    HandEvaluation* handStraightCEval = [HandEvaluator getFinalRankingOfHand:handStraightC wildCards:1];
    HandEvaluation* handStraightDEval = [HandEvaluator getFinalRankingOfHand:handStraightD wildCards:0];
    
    XCTAssert(handStraightCEval.type == Straight);
    XCTAssert(handStraightDEval.type == Straight);
    
    XCTAssert([HandEvaluator compareHand:handStraightCEval toHand:handStraightDEval] == NSOrderedDescending);
    
    // E should beat F on kicker cards
    NSArray<Card*>* handStraightE = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       [[Card alloc] initWithRank:14 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Hearts]
                                       ];
    
    NSArray<Card*>* handStraightF = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       [[Card alloc] initWithRank:13 suit:Hearts],
                                       [[Card alloc] initWithRank:12 suit:Hearts]
                                       ];
    
    HandEvaluation* handStraightEEval = [HandEvaluator getFinalRankingOfHand:handStraightE wildCards:0];
    HandEvaluation* handStraightFEval = [HandEvaluator getFinalRankingOfHand:handStraightF wildCards:0];
    
    XCTAssert(handStraightEEval.type == Straight);
    XCTAssert(handStraightFEval.type == Straight);
    
    XCTAssert([HandEvaluator compareHand:handStraightEEval toHand:handStraightFEval] == NSOrderedDescending);
    
    // G uses wild cards to beat H by filling in one gap and then reaching up to an 8
    NSArray<Card*>* handStraightG = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       ];
    
    NSArray<Card*>* handStraightH = @[ [[Card alloc] initWithRank:7 suit:Diamonds],
                                       [[Card alloc] initWithRank:4 suit:Hearts],
                                       [[Card alloc] initWithRank:6 suit:Clubs],
                                       [[Card alloc] initWithRank:5 suit:Spades],
                                       [[Card alloc] initWithRank:3 suit:Clubs],
                                       ];
    
    HandEvaluation* handStraightGEval = [HandEvaluator getFinalRankingOfHand:handStraightG wildCards:2];
    HandEvaluation* handStraightHEval = [HandEvaluator getFinalRankingOfHand:handStraightH wildCards:0];
    
    XCTAssert(handStraightGEval.type == Straight);
    XCTAssert(handStraightHEval.type == Straight);
    
    XCTAssert([HandEvaluator compareHand:handStraightGEval toHand:handStraightHEval] == NSOrderedDescending);
    
    // Now we'll just make sure it's registering some straights
    NSArray<Card*>* handPartialStraight = @[ [[Card alloc] initWithRank:5 suit:Diamonds],
                                             [[Card alloc] initWithRank:4 suit:Hearts],
                                             [[Card alloc] initWithRank:6 suit:Clubs]];
    HandEvaluation* handPartialStraightEval = [HandEvaluator getFinalRankingOfHand:handPartialStraight wildCards:2];
    XCTAssert(handPartialStraightEval.type == Straight);
    
    NSArray<Card*>* handPartialStraightWithGaps1 = @[ [[Card alloc] initWithRank:5 suit:Diamonds],
                                                      [[Card alloc] initWithRank:4 suit:Hearts],
                                                      [[Card alloc] initWithRank:8 suit:Clubs]];
    HandEvaluation* handPartialStraightWithGaps1Eval = [HandEvaluator getFinalRankingOfHand:handPartialStraightWithGaps1 wildCards:2];
    XCTAssert(handPartialStraightWithGaps1Eval.type == Straight);
    
    NSArray<Card*>* handPartialStraightWithGaps2 = @[ [[Card alloc] initWithRank:3 suit:Diamonds],
                                                      [[Card alloc] initWithRank:5 suit:Hearts],
                                                      [[Card alloc] initWithRank:9 suit:Hearts],
                                                      [[Card alloc] initWithRank:8 suit:Clubs]];
    HandEvaluation* handPartialStraightWithGaps2Eval = [HandEvaluator getFinalRankingOfHand:handPartialStraightWithGaps2 wildCards:2];
    XCTAssert(handPartialStraightWithGaps2Eval.type == Straight);
    
    // Just or laughs, check the last two with gaps. The 9 should beat the 8
    XCTAssert([HandEvaluator compareHand:handPartialStraightWithGaps1Eval toHand:handPartialStraightWithGaps2Eval] == NSOrderedAscending);
    
    //////////////////////////////////////////////////////////////
    // N of a Kind tests
    NSArray<Card*>* handPair = @[[[Card alloc] initWithRank:14 suit:Diamonds],
                                 [[Card alloc] initWithRank:14 suit:Hearts],
                                 [[Card alloc] initWithRank:13 suit:Hearts],
                                 [[Card alloc] initWithRank:2 suit:Diamonds],
                                 [[Card alloc] initWithRank:7 suit:Spades]
                                 ];
    
    HandEvaluation* pairEval = [HandEvaluator getFinalRankingOfHand:handPair wildCards:0];
    HandEvaluation* tripsEval = [HandEvaluator getFinalRankingOfHand:handPair wildCards:1];
    HandEvaluation* fourOfAKindEval = [HandEvaluator getFinalRankingOfHand:handPair wildCards:2];
    
    XCTAssert(pairEval.type == Pair);
    XCTAssert(tripsEval.type == ThreeOfAKind);
    XCTAssert(fourOfAKindEval.type == FourOfAKind);
    
    NSArray<Card*>* handTwoPair = @[[[Card alloc] initWithRank:14 suit:Diamonds],
                                 [[Card alloc] initWithRank:14 suit:Hearts],
                                 [[Card alloc] initWithRank:7 suit:Hearts],
                                 [[Card alloc] initWithRank:2 suit:Diamonds],
                                 [[Card alloc] initWithRank:7 suit:Spades]
                                 ];
    
    HandEvaluation* handTwoPairEval = [HandEvaluator getFinalRankingOfHand:handTwoPair wildCards:0];
    
    XCTAssert(handTwoPairEval.type == TwoPair);
    
    // A two pair plus one wild card will rank as a full house - although it can be interesting to see how the two pair evaluation also plays out
    HandEvaluation* handTwoPairPlusWildCardEval = [HandEvaluator getFinalRankingOfHand:handTwoPair wildCards:1];
    
    XCTAssert(handTwoPairPlusWildCardEval.type == FullHouse);
 
    //////////////////////////////////////////////////////////////
    // Extreme cases
    
    // Two crappy cards and five wilds -> Royal Flush
    NSArray<Card*>* handReadyForWildCards = @[[[Card alloc] initWithRank:2 suit:Diamonds],
                                              [[Card alloc] initWithRank:7 suit:Spades]
                                              ];
    
    HandEvaluation* handReadyForWildCardsEval = [HandEvaluator getFinalRankingOfHand:handReadyForWildCards wildCards:5];
    
    XCTAssert(handReadyForWildCardsEval.type == RoyalFlush);
}

// Assemble and sort a set of random hands from a deck. There are no asserts, this is only useful for eyeballing sample results from the deck
-(void)testRandomHands {
    // No wild cards
    NSArray* deck = [self shuffleDeck:[self createDeck]];
    
    int cardsInHand = 7;
    int deckIndex = 0;
    
    NSMutableArray<NSArray<Card*>*>* hands = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (52 / cardsInHand); i++) {
        NSIndexSet* range = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(deckIndex, cardsInHand)];
        NSArray<Card*>* hand = [deck objectsAtIndexes:range];
        [hands addObject:hand];
        deckIndex += cardsInHand;
    }
    
    NSMutableArray<HandEvaluation*>* rankings = [[NSMutableArray alloc] init];
    for (NSArray<Card*>* hand in hands) {
        HandEvaluation* handRank = [HandEvaluator getFinalRankingOfHand:hand wildCards:0];
        [rankings addObject:handRank];
    }
    
    rankings = [NSMutableArray arrayWithArray:[HandEvaluator sortHandsByRank:rankings]];
    
    NSLog(@"Hands in order from best to worst:");
    for (HandEvaluation* ranking in rankings) {
        NSLog(@"%@", ranking);
    }
    
    // TODO: Ultimately we could have this run a large number of tests and see how the hand types distribute, to see if they match the expected odds ...
}

#pragma mark Helper methods

// Shuffle the specified deck
- (NSMutableArray*)shuffleDeck: (NSMutableArray*) unshuffledDeck {
    NSMutableArray* shuffledDeck = [NSMutableArray array];
    for (int i = SIZE_OF_DECK; i > 0; i--)
    {
        int index = arc4random_uniform(i);
        [shuffledDeck addObject: unshuffledDeck[index]];
        [unshuffledDeck removeObjectAtIndex: index];
    }
    
    return shuffledDeck;
}

-(NSMutableArray*)createDeck {
    return [self createDeckOmittingSpecifiedCards:@[]];
}

-(NSMutableArray*)createDeckOmittingSpecifiedCards:(NSArray<Card*>*) cardsToOmit {
    NSMutableArray* deck = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= 4; i++)
    {
        for (int j = 2; j <= 14; j++)
        {
            Card *card = [Card alloc];
            [card setSuit:i];
            [card setRank:j];
            
            // Make sure this isn't one of the cards we're supposed to omit ...
            bool isOmitted = false;
            for (Card* c in cardsToOmit) {
                if ([c isEqual:card]) {
                    isOmitted = true;
                    break;
                }
            }
            
            if (!isOmitted) [deck addObject:card];
        }
    }
    
    return deck;
}

@end
