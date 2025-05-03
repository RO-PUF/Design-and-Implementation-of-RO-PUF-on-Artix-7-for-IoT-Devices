from numpy import zeros, append, array, clip, cumsum, transpose, where
from scipy.special import gammaincc
from time import sleep

# === Random Excursions Test ===
class RandomExcursions:
    @staticmethod
    def get_pi_value(k, x):
        if k == 0:
            return 1 - 1.0 / (2 * abs(x))
        elif k >= 5:
            return (1.0 / (2 * abs(x))) * (1 - 1.0 / (2 * abs(x))) ** 4
        else:
            return (1.0 / (4 * x * x)) * (1 - 1.0 / (2 * abs(x))) ** (k - 1)

    @staticmethod
    def test(binary_data):
        length = len(binary_data)
        sequence_x = [-1.0 if bit == '0' else 1.0 for bit in binary_data]
        cumulative_sum = cumsum(sequence_x)
        cumulative_sum = append([0], append(cumulative_sum, [0]))
        x_values = array([-4, -3, -2, -1, 1, 2, 3, 4])
        position = where(cumulative_sum == 0)[0]

        if len(position) <= 1:
            print("⚠️  Not enough zero-crossings for Random Excursions Test.")
            return [0.0] * len(x_values)

        print(f"🔍 Zero-crossing cycles found: {len(position) - 1}")
        cycles = [cumulative_sum[position[i]:position[i + 1] + 1] for i in range(len(position) - 1)]
        num_cycles = len(cycles)
        state_count = [[cycle.tolist().count(state) for state in x_values] for cycle in cycles]
        state_count = transpose(clip(state_count, 0, 5))
        su = transpose([[(sct == cycle).sum() for sct in state_count] for cycle in range(6)])
        pi = [[RandomExcursions.get_pi_value(k, state) for k in range(6)] for state in x_values]
        inner_term = num_cycles * array(pi)
        xObs = ((array(su) - inner_term) ** 2 / inner_term).sum(axis=1)
        return [gammaincc(2.5, cs / 2.0) for cs in xObs]

# === User Manual Input ===
binary_input = "1011101011010011100011000001000101111011100000010100011100001100011000100010001010000000001110000000001100011000111001111000000110111001000100100110011001111100000000000000000000000101111000100011110100000111100010010111000101000001111000111000110011010011"
#binary_input = input("Enter a binary string (e.g., 256-bit): ").strip()


# === Validate input ===
if not binary_input or any(c not in "01" for c in binary_input):
    print("❌ Invalid input! Please enter only 0s and 1s.")
else:
    print("\n\n⏳ Running tests... Please wait.")
    sleep(0.5)

    # Run tests
    rex_p = RandomExcursions.test(binary_input)

    # Display results in a table format
    print("\nTEST RESULTS: Placement Configuration L")
    print("="*72)
    print(f"      {'State':<27}{'P-value':<27}{'Result'}")
    print("="*72)

    final_pass = True
    for label, p in zip([-4, -3, -2, -1, 1, 2, 3, 4], rex_p):
        result = "PASSED" if p >= 0.01 else "FAILED"
        print(f"        {label:<10}              {p:.6f}                    {result}")
        if p < 0.01:
            final_pass = False
    print("="*72)

    # Overall Conclusion
    print("\nRandom Excursions Test Conclusion: PASSED\n\n" if final_pass else "\nRandom Excursions Test Conclusion: FAILED\n\n")
